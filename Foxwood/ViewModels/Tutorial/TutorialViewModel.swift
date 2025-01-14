//
//  TutorialViewModel.swift
//  Foxwood
//
//  Created by Alex on 10.01.2025.
//

import SwiftUI

final class TutorialViewModel: ObservableObject {
//    @AppStorage добавь для сохранения состояния при первом запуске
    @Published var tutorialState: TutorialState = .welcome

    enum TutorialState: CaseIterable {
        case welcome
        case field
        case cages
        case resources
        case tutorialEnd
    }

    func moveToNextStep() {
        guard let currentIndex = TutorialState.allCases.firstIndex(of: tutorialState),
              currentIndex < TutorialState.allCases.count - 1 else {
            return
        }
        withAnimation {
            tutorialState = TutorialState.allCases[currentIndex + 1]
        }
    }
    
    func moveToPreviousStep() {
        guard let currentIndex = TutorialState.allCases.firstIndex(of: tutorialState),
              currentIndex > 0 else {
            return
        }
        withAnimation {
            tutorialState = TutorialState.allCases[currentIndex - 1]
        }
    }
}
