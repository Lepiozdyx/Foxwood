
import SwiftUI

final class TutorialViewModel: ObservableObject {
    enum TutorialState: CaseIterable {
        case welcome
        case field
        case cages
        case resources
        case tutorialEnd
    }
    
    @Published var tutorialState: TutorialState = .welcome


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
