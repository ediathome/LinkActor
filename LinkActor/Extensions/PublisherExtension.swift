//
//  PublisherExtension.swift
//  LinkActor
//
//  Created by Martin Kolb on 22.10.22.
//

import Foundation
import Combine

extension Publisher {
  func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
    self
      .map(Result.success)
      .catch { error in
        Just(.failure(error))
      }
      .eraseToAnyPublisher()
  }
}
