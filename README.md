# DustJourney

DustJourney is a simple 3D endless runner prototype built with **SceneKit** for iOS.

## Features
- Landing UI with **Start** and **Login** buttons (Login shows a popup with username/password fields and logs the credentials to the console).
- 3D scene featuring a road, a red cube player, an omnidirectional light, and an overhead camera that follows movement.
- Continuous forward motion with periodic speed increases and progressively spawned obstacles.
- Lateral swipe controls to change lanes and a "Stop" button to end a run early.
- Collision detection with **Game Over** popup and a completion popup at the end of the path, both offering restart or return to the main menu.

## Requirements
- Xcode 15+ (iOS SceneKit project).
- iOS 15+ recommended deployment target.

## Run instructions
1. Open `DustJourney.xcodeproj` in Xcode.
2. Select an iOS simulator or device and build/run (⌘+R).
3. Tap **Start** to begin a run or **Login** to open the demo popup.

## Web demo
A WebGL/Three.js port that mirrors the iOS prototype lives in `web/`.
## Web demo
A WebGL/Three.js port that mirrors the iOS prototype lives in `web/`.

- **Sandbox (publish-ready)**: deploy the `web` folder to GitHub Pages/Netlify/Codesandbox and use the published URL for embedding. For GitHub Pages after pushing this branch, enable Pages on the main branch with `/web` as the source; the resulting URL will look like:<br>
  `https://<your-github-username>.github.io/dust-journey/web/`

- **Embed example** (replace the URL above once published):

  ```html
  <iframe
    src="https://stellar-pothos-86cd44.netlify.app/"
    width="100%"
    height="640"
    style="border: 1px solid #111; border-radius: 12px;"
    allowfullscreen
  ></iframe>
  ```
- **Diretto (per GitHub README)**: [Apri la demo su Netlify](https://stellar-pothos-86cd44.netlify.app/).
- **Local run**:
  1. `cd web`
  2. Serve statically (e.g., `python -m http.server 4173` or `npx serve .`)
  3. Open `http://localhost:4173/` (or the served URL) and click **Start**.

- **Controls/UX parity**:
  - **Start/Login** overlay matching the SceneKit menu (login writes credentials to the console).
  - Arrow keys or **A/D** to move left/right; **Stop** halts the run and shows the Game Over panel.
  - Increasing speed over time, periodic obstacle spawning, collisions with Game Over, and completion when reaching the end of the track.
