# -Memory-Match-Game
Objective
Develop a card-flipping memory game in Flutter. Players are presented with a grid of facedown cards and must find all matching pairs by flipping two cards at a time. The goal is to
complete the board in the fewest attempts and shortest time.
Game Mechanics
 Player flips two cards per turn.
 If the cards match, they stay face-up.
 If they do not match, they flip back after a brief delay.
 Game ends when all pairs are matched.
 Track number of moves and time taken.
 Optional: 2-player mode where turns alternate and scores are tracked.
Pages and Required Features
1. Home Page
 Start Game button
 Select difficulty (Easy 4x4, Medium 6x6, Hard 8x8)
 View Leaderboard or History
2. Game Page
 Grid of face-down cards (based on difficulty)
 Tap to flip cards
 Timer and move counter at top
 Flip animation and match logic
 Game over dialog with results
3. Result Dialog
 Time and moves summary
 Restart or return to home
4. History / Leaderboard Page
 List of past game results (time, moves, difficulty)
 Show top 5 performances per difficulty
 Store locally (Hive or SharedPreferences)
