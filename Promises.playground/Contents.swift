// Copyright 2018 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import PlaygroundSupport
import Promises

PlaygroundPage.current.needsIndefiniteExecution = true

enum PlaygroundError: Error {
  case invalidNumber
}

func reverse(string: String) -> Promise<String> {
  return Promise(String(string.reversed())).delay(0.1)
}

func number(from string: String) -> Promise<Int> {
  return Promise { () -> Int in
    guard let number = Int(string) else { throw PlaygroundError.invalidNumber }
    return number
  }.delay(0.1)
}

func square(number: Int) -> Int {
  return number * number
}

reverse(string: "01").then(number(from:)).then(square(number:)).then {
  print($0) // 100
}

number(from: "hello").catch {
  print($0) // invalidNumber
}
