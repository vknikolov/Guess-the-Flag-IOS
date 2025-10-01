//
//  ContentView.swift
//  Guess the Flag
//
//  Created by Veselin Nikolov on 26.09.25.
//

import SwiftUI

struct FlagImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

extension View {
    func imageStyle() -> some View {
        modifier(FlagImage())
    }
}

struct FlagButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    @State private var rotation = 0.0
    @State private var selectedFlag: Int? = nil

    var body: some View {
        Button {
            rotation += 360
            action()
        } label: {
            Image(imageName)
                .imageStyle()
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .animation(
            .spring(response: 0.5, dampingFraction: 0.6),
            value: rotation
        )
        .opacity(isSelected ? 1 : 0.1)
    }
}

struct ContentView: View {
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland",
        "Spain", "UK", "Ukraine", "US",
    ].shuffled()

    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore: Bool = false
    @State private var gameEnd: Bool = false
    @State private var scoreTitle: String = ""
    @State private var correctCount: Int = 0
    @State private var wrongCount: Int = 0
    @State private var selectedFlag: Int? = nil

    var body: some View {
        ZStack {

            RadialGradient(
                stops: [
                    .init(
                        color: Color(red: 0.1, green: 0.2, blue: 0.45),
                        location: 0.3
                    ),
                    .init(
                        color: Color(red: 0.76, green: 0.15, blue: 0.26),
                        location: 0.3
                    ),
                ],
                center: .top,
                startRadius: 200,
                endRadius: 700
            ).ignoresSafeArea()

            VStack {
                Spacer()

                Text("Guess the flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag!")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))

                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    ForEach(0..<3, id: \.self) { number in
                        FlagButton(
                            imageName: countries[number],
                            isSelected: selectedFlag == nil
                                || selectedFlag == number
                        ) {
                            flagTapped(number)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                .alert(scoreTitle, isPresented: $showingScore) {
                    Button("Continue", action: askQuestion)
                } message: {
                    Text(
                        """
                        Your score is:
                        Correct: \(correctCount)
                        Wrong: \(wrongCount)
                        """
                    )
                }

                Spacer()
                Spacer()

                Text("Your score is: \(correctCount - wrongCount)")
                    .foregroundStyle(.white)
                    .font(.title.bold())

                Spacer()
            }
            .padding()
        }
        .alert("Game Over", isPresented: $gameEnd) {
            Button("Play again?", action: reset)
        } message: {
            Text(
                """
                Your score is:
                Correct: \(correctCount)
                Wrong: \(wrongCount)
                """
            )
        }

    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct!"
            correctCount += 1
        } else {
            scoreTitle = "Wrong! That's the flag of \(countries[number])"
            wrongCount += 1
        }
        showingScore = true
        selectedFlag = number

        if (correctCount + wrongCount) == 8 {
            gameEnd = true
            showingScore = false
        }
    }

    func askQuestion() {
        selectedFlag = nil
        if (correctCount + wrongCount) < 8 {
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
        }
    }

    func reset() {
        correctCount = 0
        wrongCount = 0
        selectedFlag = nil
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}

#Preview {
    ContentView()
}
