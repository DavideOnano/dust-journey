import * as THREE from "https://cdn.jsdelivr.net/npm/three@0.165.0/build/three.module.js";

const ui = {
  menu: document.getElementById("menu"),
  message: document.getElementById("message"),
  messageTitle: document.getElementById("message-title"),
  messageBody: document.getElementById("message-body"),
  start: document.getElementById("start-btn"),
  login: document.getElementById("login-btn"),
  stop: document.getElementById("stop-btn"),
  restart: document.getElementById("restart-btn"),
  backToMenu: document.getElementById("menu-btn"),
  speedChip: document.getElementById("speed-chip"),
  distanceChip: document.getElementById("distance-chip"),
  loginDialog: document.getElementById("login-dialog"),
  loginSubmit: document.getElementById("login-submit"),
  loginUsername: document.getElementById("login-username"),
  loginPassword: document.getElementById("login-password"),
};

const config = {
  roadLength: 120,
  roadWidth: 2,
  startingSpeed: 0.1,
  speedIncrease: 0.05,
  speedInterval: 5,
  obstacleInterval: 10,
  obstacleBatch: 3,
  collisionDistance: 0.45,
  completionZ: -100,
};

const state = {
  running: false,
  moveSpeed: config.startingSpeed,
  speedTimer: 0,
  obstacleTimer: 0,
  distance: 0,
  gameCompleted: false,
  obstacles: [],
};

let renderer;
let scene;
let camera;
let player;
const clock = new THREE.Clock();

init();
animate();
attachUI();

function init() {
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x05070d);

  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setClearColor(0x05070d);
  document.getElementById("canvas-container").appendChild(renderer.domElement);

  camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 200);
  camera.position.set(0, 5, 5);

  const ambient = new THREE.AmbientLight(0xffffff, 0.55);
  const keyLight = new THREE.DirectionalLight(0xffffff, 0.9);
  keyLight.position.set(2, 8, 5);
  scene.add(ambient, keyLight);

  addRoad();
  addPlayer();
  addInitialObstacles();

  window.addEventListener("resize", handleResize);
  window.addEventListener("keydown", handleKeydown);
}

function addRoad() {
  const roadTexture = createRoadTexture();
  roadTexture.wrapS = roadTexture.wrapT = THREE.RepeatWrapping;
  roadTexture.repeat.set(1, 20);

  const material = new THREE.MeshStandardMaterial({
    map: roadTexture,
    color: 0x6d6f78,
    roughness: 0.9,
    metalness: 0.1,
  });

  const geometry = new THREE.BoxGeometry(config.roadWidth, 0.1, config.roadLength);
  const road = new THREE.Mesh(geometry, material);
  road.position.set(0, -0.05, -config.roadLength / 2);
  scene.add(road);
}

function createRoadTexture() {
  const canvas = document.createElement("canvas");
  canvas.width = 64;
  canvas.height = 256;
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "#6d6f78";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = "rgba(255,255,255,0.18)";
  const stripeWidth = 6;
  ctx.fillRect(canvas.width / 2 - stripeWidth / 2, 0, stripeWidth, canvas.height);
  ctx.fillStyle = "rgba(0,0,0,0.2)";
  ctx.fillRect(0, 0, canvas.width, 18);
  ctx.fillRect(0, 48, canvas.width, 18);
  ctx.fillRect(0, 96, canvas.width, 18);
  ctx.fillRect(0, 144, canvas.width, 18);
  ctx.fillRect(0, 192, canvas.width, 18);
  const texture = new THREE.CanvasTexture(canvas);
  texture.anisotropy = 8;
  return texture;
}

function addPlayer() {
  const geometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);
  const material = new THREE.MeshStandardMaterial({ color: 0xff4040, roughness: 0.4, metalness: 0.3 });
  player = new THREE.Mesh(geometry, material);
  player.position.set(0, 0.25, 0);
  scene.add(player);
}

function addInitialObstacles() {
  for (let i = 1; i <= 20; i += 1) {
    spawnObstacle(-i * 5);
  }
}

function spawnObstacle(zPosition) {
  const geometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);
  const material = new THREE.MeshStandardMaterial({ color: 0x8b572a });
  const obstacle = new THREE.Mesh(geometry, material);
  obstacle.position.set(THREE.MathUtils.randFloatSpread(config.roadWidth * 0.75), 0.25, zPosition);
  obstacle.name = "obstacle";
  scene.add(obstacle);
  state.obstacles.push(obstacle);
}

function resetObstacles() {
  state.obstacles.forEach((obs) => scene.remove(obs));
  state.obstacles = [];
  addInitialObstacles();
}

function attachUI() {
  ui.start.addEventListener("click", startGame);
  ui.stop.addEventListener("click", () => stopGame("Game Over", "Hai fermato la corsa."));
  ui.restart.addEventListener("click", restartAfterMessage);
  ui.backToMenu.addEventListener("click", showMenu);
  ui.login.addEventListener("click", openLoginDialog);
  ui.loginSubmit.addEventListener("click", handleLoginSubmit);
}

function startGame() {
  state.running = true;
  state.gameCompleted = false;
  state.moveSpeed = config.startingSpeed;
  state.speedTimer = 0;
  state.obstacleTimer = 0;
  state.distance = 0;
  player.position.set(0, 0.25, 0);
  resetObstacles();
  hidePanels();
}

function restartAfterMessage() {
  hidePanels();
  startGame();
}

function showMenu() {
  state.running = false;
  ui.menu.classList.remove("hidden");
  ui.message.classList.add("hidden");
}

function openLoginDialog() {
  ui.loginUsername.value = "";
  ui.loginPassword.value = "";
  ui.loginDialog.showModal();
}

function handleLoginSubmit(event) {
  event.preventDefault();
  const username = ui.loginUsername.value;
  const password = ui.loginPassword.value;
  console.log("Login - Username:", username, "Password:", password);
  ui.loginDialog.close();
}

function hidePanels() {
  ui.menu.classList.add("hidden");
  ui.message.classList.add("hidden");
}

function stopGame(title, body) {
  state.running = false;
  ui.messageTitle.textContent = title;
  ui.messageBody.textContent = body;
  ui.message.classList.remove("hidden");
}

function animate() {
  requestAnimationFrame(animate);
  const delta = clock.getDelta();
  if (state.running) {
    update(delta);
  }
  renderer.render(scene, camera);
}

function update(delta) {
  player.position.z -= state.moveSpeed;
  state.distance = Math.abs(player.position.z);
  updateCamera();
  updateSpeedTimer(delta);
  updateObstacleTimer(delta);
  cullObstacles();
  detectCollisions();
  checkCompletion();
  updateHUD();
}

function updateCamera() {
  camera.position.set(player.position.x, player.position.y + 5, player.position.z + 5);
  camera.lookAt(player.position.x, player.position.y, player.position.z - 2);
}

function updateSpeedTimer(delta) {
  state.speedTimer += delta;
  if (state.speedTimer >= config.speedInterval) {
    state.moveSpeed += config.speedIncrease;
    state.speedTimer = 0;
  }
}

function updateObstacleTimer(delta) {
  state.obstacleTimer += delta;
  if (state.obstacleTimer >= config.obstacleInterval) {
    state.obstacleTimer = 0;
    const leadZ = player.position.z - THREE.MathUtils.randFloat(6, 10);
    for (let i = 0; i < config.obstacleBatch; i += 1) {
      spawnObstacle(leadZ - i * THREE.MathUtils.randFloat(2, 4));
    }
  }
}

function cullObstacles() {
  state.obstacles = state.obstacles.filter((obs) => {
    if (obs.position.z - player.position.z > 10) {
      scene.remove(obs);
      return false;
    }
    return true;
  });
}

function detectCollisions() {
  for (const obs of state.obstacles) {
    if (Math.abs(obs.position.z - player.position.z) < config.collisionDistance * 2) {
      const dx = Math.abs(obs.position.x - player.position.x);
      const dz = Math.abs(obs.position.z - player.position.z);
      if (dx < config.collisionDistance && dz < config.collisionDistance) {
        stopGame("Game Over", "Hai colpito un ostacolo!");
        return;
      }
    }
  }
}

function checkCompletion() {
  if (!state.gameCompleted && player.position.z <= config.completionZ) {
    state.gameCompleted = true;
    stopGame("Complimenti!", "Hai completato il percorso.");
  }
}

function updateHUD() {
  ui.speedChip.textContent = `Speed: ${state.moveSpeed.toFixed(2)}`;
  ui.distanceChip.textContent = `Distanza: ${state.distance.toFixed(1)}`;
}

function handleKeydown(event) {
  if (!state.running) return;
  const step = 0.5;
  if (["ArrowLeft", "a", "A"].includes(event.key)) {
    player.position.x = clamp(player.position.x - step, -config.roadWidth * 0.375, config.roadWidth * 0.375);
  }
  if (["ArrowRight", "d", "D"].includes(event.key)) {
    player.position.x = clamp(player.position.x + step, -config.roadWidth * 0.375, config.roadWidth * 0.375);
  }
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function handleResize() {
  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
}
