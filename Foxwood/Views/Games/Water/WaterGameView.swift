//
//  WaterGameView.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import SwiftUI

enum Direction {
    case up, down, left, right
}

struct WaterGameView: View {
    @State private var startPosition: CGPoint = .zero
    @State private var positions = [CGPoint(x: 0, y: 0)]
    @State private var waterPosition = CGPoint(x: 0, y: 0)
    
    @State private var isStarted = true
    @State private var gameOver = false
    
    @State private var score = 0
    
    @State private var direction = Direction.down
    
    let snakeSize: CGFloat = 30
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
   
            ZStack {
                BackgroundView()
                VStack {
                    HStack {
                        HStack {
                            Text("Score")
                                .fontModifier(16)
                            
                            Text("\(score)")
                                .fontModifier(16)
                        }
                        
                        Spacer()
                        
                        Button {
                            startGame()
                        } label: {
                            Text("Restart")
                                .fontModifier(16)
                                .frame(width: 105, height: 30)
                                .background(Color.secondary)
                                .clipShape(.capsule)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                ForEach(0..<positions.count, id: \.self) { index in
                    // MARK: Snake
                    Circle()
                        .foregroundStyle(.yellow)
                        .shadow(color: .red, radius: 1)
                        .overlay(Capsule().stroke(.black, lineWidth: 1))
                        .frame(width: snakeSize, height: snakeSize)
                        .position(positions[index])
                }
                
                // MARK: Water
                Image(.waterdrop)
                    .resizable()
                    .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                    .frame(width: snakeSize, height: snakeSize * 1.3)
                    .position(waterPosition)
            }
            .onAppear {
                withAnimation(.easeInOut) {
                    waterPosition = changePosition()
                    positions[0] = changePosition()
                }
            }
        }
        
        // MARK: Alert
        .alert(isPresented: $gameOver) {
            Alert(title: Text("Game Over"), message: Text("Your Score is: \(score)"), primaryButton: .default(Text("Dismiss"), action: {
                gameOver.toggle()
                isStarted.toggle()
            }), secondaryButton: .default(Text("Restart"), action: {
                startGame()
            }))
        }
        
        // MARK: Gestures
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if isStarted {
                        withAnimation {
                            startPosition = gesture.location
                            isStarted.toggle()
                        }
                    }
                }
                .onEnded { gesture in
                    let xDist = abs(gesture.location.x - startPosition.x)
                    let yDist = abs(gesture.location.y - startPosition.y)
                    
                    if startPosition.y < gesture.location.y && yDist > xDist {
                        direction = Direction.down
                    } else if startPosition.y > gesture.location.y && yDist > xDist {
                        direction = Direction.up
                    } else if startPosition.x > gesture.location.x && yDist < xDist {
                        direction = Direction.right
                    } else if startPosition.x < gesture.location.x && yDist < xDist {
                        direction = Direction.left
                    }
                    
                    isStarted.toggle()
                }
        )
        
        // MARK: Time frequency
        .onReceive(timer) { _ in
            if !gameOver {
                withAnimation(.linear(duration: 0.15)) {
                    changeDirection()
                }
                
                if positions[0] == waterPosition {
                    withAnimation(.spring()) {
                        positions.append(positions[0])
                    }
                    
                    waterPosition = changePosition()
                    score += 1
                }
            }
        }
    }
    
    let minX = UIScreen.main.bounds.minX
    let maxX = UIScreen.main.bounds.maxX
    let minY = UIScreen.main.bounds.minY
    let maxY = UIScreen.main.bounds.maxY
    
    // MARK: Random positions for Snake
    func changePosition() -> CGPoint {
        let rows = Int(maxX / snakeSize)
        let columns = Int(maxY / snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<columns) * Int(snakeSize)
        
        let randomPosition = CGPoint(x: randomX, y: randomY)
        return randomPosition
    }
    
    func changeDirection() {
        if positions[0].x < minX || positions[0].x > maxX && !gameOver {
            gameOver.toggle()
        } else if positions[0].y < minY || positions[0].y > maxY && !gameOver {
            gameOver.toggle()
        }
        
        var prev = positions[0]
        
        if direction == .down {
            positions[0].y += snakeSize
        } else if direction == .up {
            positions[0].y -= snakeSize
        } else if direction == .left {
            positions[0].x += snakeSize
        } else {
            positions[0].x -= snakeSize
        }
        
        for index in 1..<positions.count {
            let current = positions[index]
            positions[index] = prev
            prev = current
        }
    }
    
    // MARK: Start game func
    func startGame() {
        withAnimation(.easeInOut) {
            score = 0
            positions = [CGPoint(x: 0, y: 0)]
            
            gameOver = false
            isStarted = true
            waterPosition = changePosition()
            positions[0] = changePosition()
            changeDirection()
        }
    }
}

#Preview {
    WaterGameView()
}
