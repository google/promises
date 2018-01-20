[TOC]

# Introduction

## The problem with async code

Typically, async operations take a completion handler in a form of a block,
which is called to provide either a result or an error. To perform more than one
async operation, you have to nest the second one inside the completion block of
the first one, and also handle an error gracefully. Often such nesting becomes
painful to follow or modify:

Objective-C:

```objectivec
- (void)getCurrentUserContactsAvatars:(void (^)(NSArray<UIImage *> *, NSError *))completion {
  [MyClient getCurrentUserWithCompletion:^(MyUser *currentUser, NSError *error) {
    if (error) {
      completion(nil, error);
      return;
    }
    [MyClient getContactsForUser:currentUser
                      completion:^(NSArray<MyContact *> *contacts, NSError *error) {
      if (error) {
        completion(nil, error);
        return;
      }
      if (contacts.count == 0) {
        completion(@[], nil);
        return;
      }
      NSMutableArray<UIImage *> *avatars = [NSMutableArray array];
      NSUInteger __block count = contacts.count;
      BOOL __block errorReported = NO;
      for (NSUInteger index = 0; index < count; ++index) {
        [avatars addObject:[NSNull null]];
      }
      [contacts enumerateObjectsUsingBlock:^(MyContact *contact, NSUInteger index, BOOL __unused *_) {
        [MyClient getAvatarForContact:contact completion:^(UIImage *avatar, NSError *error) {
          if (errorReported) {
            return;
          }
          if (error) {
            completion(nil, error);
            errorReported = YES;
            return;
          }
          if (avatar) {
            avatars[index] = avatar;
          }
          if (--count == 0) {
            completion(avatars, nil);
          }
        }];
      }];
    }];
  }];
}
```

Swift:

```swift
func getCurrentUserContactAvatars(_ completion: ([UIImage]?, Error?) -> Void) {
  MyClient.getCurrentUser() { currentUser, error in
    guard error == nil else {
      completion(nil, error)
      return
    }
    MyClient.getContacts(currentUser) { contacts, error in
      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let contacts = contacts, !contacts.isEmpty() else {
        completion([UIImage](), nil)
        return
      }
      var count = contacts.count
      var avatars = [UIImage](repeating: nil, count: count)
      var errorReported = false
      for (index, contact) in contacts.enumerated() {
        MyClient.getAvatar(contact) { avatar, error in
          if (errorReported) {
            return
          }
          guard error == nil {
            completion(nil, error)
            errorReported = true
            return
          }
          if let avatar = avatar {
            avatars[index] = avatar
          }
          count -= 1
          if count == 0 {
            completion(avatars.flatMap { $0 }, nil)
          }
        }
      }
    }
  }
}
```

Which could be used as:

Objective-C:

```objectivec
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self getCurrentUserContactsAvatars:^(NSArray<UIImage *> *avatars, NSError *error) {
    if (error) {
      [self showErrorAlert:error];
    } else {
      [self updateAvatars:avatars];
    }
  }];
}
```

Swift:

```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)

  getCurrentUserContactsAvatars() { avatars, error in
    if (error) {
      showErrorAlert(error)
    } else {
      updateAvatars(avatars)
    }
  }
}
```

## Promises to the rescue

The code sample above, when converted into promises, could look like the
following (assuming you've got [`-fbl_map`](https://github.com/google/functional-objc/blob/master/README.md#map)
method on `NSArray`):

Objective-C:

```objectivec
- (FBLPromise<NSArray<UIImage *> *> *)getCurrentUserContactsAvatars {
  return [[[MyClient getCurrentUser] then:^id(MyUser *currentUser) {
    return [MyClient getContactsForUser:currentUser];
  }] then:^id(NSArray<MyContact *> *contacts) {
    return [FBLPromise all:[contacts fbl_map:^id(MyContact *contact) {
      return [MyClient getAvatarForContact:contact];
    }]];
  }];
```

Swift:

```swift
func getCurrentUserContactsAvatars() -> Promise<[UIImage]> {
  return MyClient.getCurrentUser().then(MyClient.getContacts).then { contacts in
    all(contacts.map(MyClient.getAvatar))
  }
}
```

**That's all!**

Now use it like:

Objective-C:

```objectivec
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [[[self getCurrentUserContactsAvatars] then:^id(NSArray<UIImage *> *avatars) {
    [self updateAvatars:avatars];
    return avatars;
  }] catch:^(NSError *error) {
    [self showErrorAlert:error];
  }];
}
```

Swift:

```swift
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)

  getCurrentUserContactsAvatars().then(updateAvatars).catch(showErrorAlert)
}
```

## What is a promise?

In general, a promise represents the _eventual result_ of an asynchronous task,
respectively the _error reason_ when the task fails. Similar concepts are also
called _futures_ (see also wiki article: [Futures and
promises](http://en.wikipedia.org/wiki/Futures_and_promises)).

A promise can be in one of three states:

-   pending - the promise is unresolved and the result is not yet available
-   fulfilled - the promise is resolved with some value
-   rejected - the promise is resolved with some error

Once fulfilled or rejected, a promise can never change its state in the future.
Also, it can have an infinite number of observers waiting for it to be resolved.
Once resolved, either a value or an error is broadcasted to all observers. Each
observer, returns a new promise on subscribe, which, in turn, will be resolved
with another value or error the observer provides. This enables chaining
promises together to create a pipeline into a pipeline of transforming values
which are computed asynchronously on different threads.

Thus, promises are a way of formalizing completion handlers to make chaining
async tasks much easier. For example, it becomes trivial to write reusable code
that can:

-   perform a chain of dependent asynchronous operations with one completion
    block at the end
-   have a fall-through behavior for errors to the nearest error handler
-   perform many independent asynchronous operations simultaneously with one
    completion block
-   race many asynchronous operations and return the value of the first to
    complete
-   retry asynchronous operations
-   and much more
