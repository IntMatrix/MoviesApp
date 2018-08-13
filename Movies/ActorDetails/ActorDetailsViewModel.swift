//
//  ActorDetailsViewModel.swift
//  Movies
//
//  Created by Maria Deygin on 8/3/18.
//  Copyright © 2018 Maria Deygin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ActorDetailsViewModel: NSObject {

    var actor: BehaviorSubject<Actor>!
    var networkService = NetworkService()
    let disposeBag = DisposeBag()

    func setupActor(_ actor:Actor) {
        self.actor = BehaviorSubject<Actor>(value: actor)
        
        loadDetails(actor).subscribe().disposed(by: disposeBag)
    }
    
    private func loadDetails(_ actor: Actor) -> Observable<Void> {
        guard let id = actor.id else { return Observable.empty()}
        
        return self.networkService.getActorDetails(id).asObservable()
            .do(onNext: { (actorDetails) in
                self.actor.onNext(actorDetails)
            }).map{ _ in }
    }
    
    func portrait(for actor: Actor) -> Observable<UIImage?> {
        guard let portraitPath = actor.profilePath else { return Observable.error(Error.noImagePath) }
        return networkService.getImage(path: portraitPath, size: .big).asObservable()
    }
    
}
