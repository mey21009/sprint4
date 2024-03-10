import SwiftUI

// Define a SwiftUI view for the game board
struct GameBoardView: View {
    @ObservedObject var game: RiskGame // Observe changes to the game state
    
    var body: some View {
        VStack {
            Text("Risk Game")
                .font(.largeTitle)
                .padding()
            
            // Display game board and player information here
            ForEach(0..<game.board.count, id: \.self) { index in
                SquareView(square: game.board[index])
            }
            
            Button("Take Turn") {
                game.takeTurn()
            }
            .padding()
        }
    }
}

// Define a SwiftUI view for a single square on the game board
struct SquareView: View {
    var square: Square
    
    var body: some View {
        VStack {
            if let owner = square.owner {
                Text("Owned by Player \(owner + 1)")
            } else {
                Text("Unowned")
            }
            Text("Tokens: \(square.tokens)")
        }
        .padding()
        .border(Color.black) // Add border for visibility
    }
}

// Define the RiskGame class
class RiskGame: ObservableObject {
    let boardSize = 12 // Number of squares on the game board
    @Published var board: [Square] = [] // Array to store the game board
    
    var players: Int // Number of players
    var playerTokens: [Int] // Array to store the number of tokens for each player
    
    var currentPlayerIndex = 0 // Index of the current player
    
    init(players: Int) {
        self.players = players
        self.playerTokens = Array(repeating: 6, count: players) // Start each player with 6 tokens
        
        // Initialize the game board
        for _ in 0..<boardSize {
            board.append(Square(owner: nil, tokens: 0))
        }
        
        // Randomly assign starting squares to players
        assignStartingSquares()
    }
    
    // Function to randomly assign starting squares to players
    func assignStartingSquares() {
        var availableSquares = Array(0..<boardSize)
        for playerIndex in 0..<players {
            let randomSquareIndex = Int.random(in: 0..<availableSquares.count)
            let squareIndex = availableSquares.remove(at: randomSquareIndex)
            board[squareIndex].owner = playerIndex
            board[squareIndex].tokens = 1
        }
    }
    
    // Function to handle a player's turn
    func takeTurn() {
        print("Player \(currentPlayerIndex + 1)'s turn")
        print("Current board state:")
        displayBoard()
        print("Your tokens: \(playerTokens[currentPlayerIndex])")
        
        // Prompt the player to choose an action
        print("Choose an action:")
        print("1. Claim an unowned square")
        print("2. Reinforce one of your squares")
        print("3. Attack an opponent's square")
        let choice = getInput(prompt: "Enter your choice (1-3):")
        
        switch choice {
        case 1:
            claimSquare()
        case 2:
            reinforceSquare()
        case 3:
            attackSquare()
        default:
            print("Invalid choice")
        }
        
        // Check if the game is over
        if isGameOver() {
            print("Game over! Player \(currentPlayerIndex + 1) wins!")
        } else {
            // Move to the next player's turn
            currentPlayerIndex = (currentPlayerIndex + 1) % players
        }
    }
    
    // Function to display the current state of the game board
    func displayBoard() {
        for (index, square) in board.enumerated() {
            if let owner = square.owner {
                print("Square \(index + 1): Owned by Player \(owner + 1), Tokens: \(square.tokens)")
            } else {
                print("Square \(index + 1): Unowned, Tokens: \(square.tokens)")
            }
        }
    }
    
    // Function to get user input
    func getInput(prompt: String) -> Int {
        print(prompt, terminator: " ")
        guard let input = readLine(), let choice = Int(input) else {
            print("Invalid input. Please enter a number.")
            return getInput(prompt: prompt)
        }
        return choice
    }
    
    // Other game logic functions (claimSquare, reinforceSquare, attackSquare, rollDice, isGameOver) go here...
}

// Create an instance of RiskGame and wrap it in a SwiftUI app
@main
struct RiskGameApp: App {
    @StateObject var game = RiskGame(players: 4)
    
    var body: some Scene {
        WindowGroup {
            GameBoardView(game: game)
        }
    }
}
