import UIKit
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var playerNode: SCNNode!
    var scnView: SCNView!
    var cameraNode: SCNNode!
    var gameCompleted = false
    var gameStopped = true // Inizialmente fermo fino alla pressione di "Start"
    var startButtonNode: SCNNode!  // Nodo per il pulsante Start

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configura la vista della scena
        setupScene()
        
        // Aggiungi la schermata iniziale con il pulsante "Start"
        // Mostra la schermata principale con due pulsanti
               showMainMenu()
    }
    
    func showMainMenu() {
           // Rimuovi tutte le subview precedenti (se presenti)
           self.view.subviews.forEach { $0.removeFromSuperview() }
           
           // Crea il pulsante Start
           let startButton = UIButton(type: .system)
           startButton.setTitle("Start", for: .normal)
           startButton.frame = CGRect(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2 - 25, width: 100, height: 50)
           startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
           startButton.backgroundColor = UIColor.systemBlue
           startButton.setTitleColor(.white, for: .normal)
           startButton.layer.cornerRadius = 10
           startButton.layer.shadowColor = UIColor.black.cgColor
           startButton.layer.shadowOpacity = 0.3
           startButton.layer.shadowOffset = CGSize(width: 0, height: 2)
           startButton.layer.shadowRadius = 4
           self.view.addSubview(startButton)
           
           // Crea il pulsante Login
           let loginButton = UIButton(type: .system)
           loginButton.setTitle("Login", for: .normal)
           loginButton.frame = CGRect(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2 + 50, width: 100, height: 50)
           loginButton.addTarget(self, action: #selector(showLoginPopup), for: .touchUpInside)
           loginButton.backgroundColor = UIColor.systemGreen
           loginButton.setTitleColor(.white, for: .normal)
           loginButton.layer.cornerRadius = 10
           loginButton.layer.shadowColor = UIColor.black.cgColor
           loginButton.layer.shadowOpacity = 0.3
           loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
           loginButton.layer.shadowRadius = 4
           self.view.addSubview(loginButton)
       }
    @objc func showLoginPopup() {
          let alert = UIAlertController(title: "Login", message: "Inserisci le tue credenziali", preferredStyle: .alert)
          alert.addTextField { textField in
              textField.placeholder = "Username"
          }
          alert.addTextField { textField in
              textField.placeholder = "Password"
              textField.isSecureTextEntry = true
          }
          alert.addAction(UIAlertAction(title: "Accedi", style: .default, handler: { _ in
              let username = alert.textFields?[0].text
              let password = alert.textFields?[1].text
              // Gestisci le credenziali qui, ad esempio convalidazione o richiesta server
              print("Username: \(username ?? "") - Password: \(password ?? "")")
          }))
          alert.addAction(UIAlertAction(title: "Annulla", style: .cancel, handler: nil))
          
          self.present(alert, animated: true, completion: nil)
      }

    // Configura la scena e la vista
    func setupScene() {
        scnView = self.view as? SCNView
        let scene = SCNScene()
        
        scnView.scene = scene
        scnView.delegate = self
        scnView.showsStatistics = false
        scnView.antialiasingMode = .multisampling4X
        scnView.backgroundColor = UIColor.black

        // Crea la strada
        let roadLength: CGFloat = 100
        let road = SCNBox(width: 2, height: 0.1, length: roadLength, chamferRadius: 0)
        let roadMaterial = SCNMaterial()
        roadMaterial.diffuse.contents = UIColor.gray
        road.materials = [roadMaterial]
        let roadNode = SCNNode(geometry: road)
        roadNode.position = SCNVector3(0, -0.05, -roadLength / 2)
        scene.rootNode.addChildNode(roadNode)

        // Crea il player
        let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        let playerMaterial = SCNMaterial()
        playerMaterial.diffuse.contents = UIColor.red
        box.materials = [playerMaterial]
        playerNode = SCNNode(geometry: box)
        playerNode.position = SCNVector3(0, 0.25, 0)
        scene.rootNode.addChildNode(playerNode)

        // Aggiungi una luce
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 5, 5)
        scene.rootNode.addChildNode(lightNode)

        // Aggiungi la telecamera che segue il player dall'alto
        cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 5, 5)
        cameraNode.eulerAngles.x = -.pi / 4
        scene.rootNode.addChildNode(cameraNode)

        // Aggiungi ostacoli
        addObstacles(to: scene)

        // Aggiungi gesture recognizer
        addGestureRecognizers(to: scnView)

        // Aggiungi il pulsante di stop
        addStopButton()
        
        // Imposta la telecamera come punto di vista
        scnView.pointOfView = cameraNode
    }

    // Mostra la schermata iniziale con il pulsante "Start"
    func showStartScreen() {
            gameStopped = false
            gameCompleted = false

            // Crea un piano che funge da pulsante
            let buttonGeometry = SCNPlane(width: 2, height: 1)
            let buttonMaterial = SCNMaterial()
            buttonMaterial.diffuse.contents = UIColor.blue
            buttonGeometry.materials = [buttonMaterial]
            
            startButtonNode = SCNNode(geometry: buttonGeometry)
            startButtonNode.position = SCNVector3(0, 0, -3)  // Posizionalo davanti alla telecamera
            scnView.scene?.rootNode.addChildNode(startButtonNode)

            // Aggiungi testo al pulsante
            let textGeometry = SCNText(string: "Start", extrusionDepth: 1)
            textGeometry.font = UIFont.systemFont(ofSize: 0.3)
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = UIColor.white
            textGeometry.materials = [textMaterial]
            
            let textNode = SCNNode(geometry: textGeometry)
            textNode.position = SCNVector3(-0.5, -0.2, 0.1)  // Centra il testo
            startButtonNode.addChildNode(textNode)

            // Aggiungi un gesture recognizer per toccare il pulsante
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            scnView.addGestureRecognizer(tapGesture)
        }

    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
           // Rileva la posizione del tocco
           let location = gestureRecognize.location(in: scnView)
           let hitResults = scnView.hitTest(location, options: [:])

           // Controlla se l'utente ha toccato il pulsante "Start"
           if let hit = hitResults.first, hit.node == startButtonNode {
               // Rimuove il pulsante dalla scena
               startButtonNode.removeFromParentNode()

               // Avvia il gioco
               startGame()
           }
       }
    
    // Funzione per avviare il gioco
    var moveSpeed: CGFloat = 0.1  // Velocità iniziale
    var speedIncreaseInterval: TimeInterval = 5.0  // Ogni quanto tempo aumentare la velocità

    @objc func startGame() {
        gameStopped = false
        self.view.subviews.forEach { $0.removeFromSuperview() } // Rimuove il pulsante di start

        // Reset della velocità iniziale
        moveSpeed = 0.1

        // Rimuovi tutte le azioni in corso e riparti da zero
        playerNode.removeAllActions()
        
        movePlayer()
        increaseSpeedOverTime()
        increaseObstaclesOverTime()  // Aggiunge ostacoli nel tempo
    }



    func movePlayer() {
        // Rimuove solo l'azione di movimento, senza interferire con altre azioni
        playerNode.removeAction(forKey: "movePlayer")

        // Crea una nuova azione con la velocità attuale
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -moveSpeed, duration: 0.1)
        let repeatMoveAction = SCNAction.repeatForever(moveForwardAction)

        // Esegui l'azione di movimento
        playerNode.runAction(repeatMoveAction, forKey: "movePlayer")
    }


    func increaseSpeedOverTime() {
        let waitAction = SCNAction.wait(duration: speedIncreaseInterval)
        let increaseSpeedAction = SCNAction.run { _ in
            // Aumenta la velocità
            self.moveSpeed += 0.05  // Incremento graduale
            
            // Resetta l'azione di movimento per applicare la nuova velocità
            self.movePlayer()
        }

        // Crea una sequenza che aspetta e poi aumenta la velocità
        let sequenceAction = SCNAction.sequence([waitAction, increaseSpeedAction])
        let repeatIncreaseAction = SCNAction.repeatForever(sequenceAction)

        // Esegui l'azione sul playerNode per aumentare gradualmente la velocità
        playerNode.runAction(repeatIncreaseAction, forKey: "increaseSpeed")
    }




    // Funzione per aggiungere ostacoli
    func addObstacles(to scene: SCNScene) {
        for i in 1...20 {
            let obstacle = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
            let obstacleMaterial = SCNMaterial()
            obstacleMaterial.diffuse.contents = UIColor.brown
            obstacle.materials = [obstacleMaterial]
            let obstacleNode = SCNNode(geometry: obstacle)
            let randomX = Float.random(in: -0.75...0.75)
            let randomZ = Float(-i * 5)
            obstacleNode.position = SCNVector3(randomX, 0.25, randomZ)
            obstacleNode.name = "obstacle"
            scene.rootNode.addChildNode(obstacleNode)
        }
    }
    func increaseObstaclesOverTime() {
        let waitAction = SCNAction.wait(duration: 10.0)  // Aggiunge nuovi ostacoli ogni 10 secondi
        let addObstacleAction = SCNAction.run { _ in
            // Aggiungi un nuovo gruppo di ostacoli
            self.addMoreObstacles()
        }

        let sequenceAction = SCNAction.sequence([waitAction, addObstacleAction])
        let repeatIncreaseObstacles = SCNAction.repeatForever(sequenceAction)

        playerNode.runAction(repeatIncreaseObstacles)
    }

    func addMoreObstacles() {
        guard let scene = scnView.scene else { return }

        // Rimuovi gli ostacoli che sono oltre una certa distanza dietro il player
        let thresholdZ: Float = 10.0
        for node in scene.rootNode.childNodes {
            if node.name == "obstacle" && node.position.z > playerNode.position.z + thresholdZ {
                node.removeFromParentNode()
            }
        }

        // Aggiungi nuovi ostacoli
        for _ in 1...3 {  // Ridotto il numero di ostacoli aggiunti per volta
            let obstacle = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
            let obstacleMaterial = SCNMaterial()
            obstacleMaterial.diffuse.contents = UIColor.brown
            obstacle.materials = [obstacleMaterial]
            let obstacleNode = SCNNode(geometry: obstacle)
            let randomX = Float.random(in: -0.75...0.75)
            let randomZ = Float(-Float.random(in: 5...10))
            obstacleNode.position = SCNVector3(randomX, 0.25, playerNode.position.z - randomZ)
            obstacleNode.name = "obstacle"
            scene.rootNode.addChildNode(obstacleNode)
        }
    }


    // Aggiunge i gesture recognizer per muovere il player
    func addGestureRecognizers(to scnView: SCNView) {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
    }

    // Gestisce lo swipe del player
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let moveDistance: Float = 0.5
        var newPosition = playerNode.position

        if gesture.direction == .left {
            newPosition.x -= moveDistance
        } else if gesture.direction == .right {
            newPosition.x += moveDistance
        }

        // Limita il movimento del player alla larghezza della strada
        newPosition.x = max(min(newPosition.x, 0.75), -0.75)

        // Anima lo spostamento del player
        let moveAction = SCNAction.move(to: newPosition, duration: 0.2)
        playerNode.runAction(moveAction)
    }

    // Funzione di aggiornamento per rilevare collisioni e completamento gioco
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !gameStopped else { return } // Se il gioco è fermo, non fare nulla

        // Aggiorna la posizione della telecamera per seguire il player dall'alto
        cameraNode.position = SCNVector3(playerNode.position.x, playerNode.position.y + 5, playerNode.position.z + 5)

        // Verifica prima se il gioco è completato
        checkGameCompletion()

        // Verifica le collisioni solo se il gioco non è completato
        if !gameCompleted {
            checkCollisions()
        }
    }




    // Verifica le collisioni tra il player e gli ostacoli
    func checkCollisions() {
        guard let scene = scnView.scene, !gameCompleted else { return }

        // Considera solo gli ostacoli vicini al player
        let proximityThreshold: Float = 2.0  // Controlla solo ostacoli molto vicini al player
        for node in scene.rootNode.childNodes {
            if node.name == "obstacle" && abs(node.position.z - playerNode.position.z) < proximityThreshold {
                let distance = playerNode.position - node.position
                let collisionThreshold: Float = 0.5

                if abs(distance.x) < collisionThreshold && abs(distance.z) < collisionThreshold {
                    gameStopped = true
                    playerNode.removeAllActions()

                    DispatchQueue.main.async {
                        self.showGameOverPopup()
                    }

                    return
                }
            }
        }
    }




    // Verifica se il gioco è stato completato
    func checkGameCompletion() {
        // Verifica se il player ha raggiunto o superato il limite finale
        if playerNode.position.z <= -100 && !gameCompleted {
            gameCompleted = true
            gameStopped = true

            // Ferma tutte le azioni del player e altri nodi
            playerNode.removeAllActions()

            // Mostra il popup di completamento del gioco
            DispatchQueue.main.async {
                self.showCompletionPopup()
            }
        }
    }

    // Mostra un popup di completamento gioco
    func showCompletionPopup() {
        let alert = UIAlertController(title: "Complimenti!", message: "Hai completato il gioco!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ricomincia", style: .default) { _ in
            self.restartGame()
        })
        alert.addAction(UIAlertAction(title: "Esci", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Mostra un popup di Game Over
    func showGameOverPopup() {
        let alert = UIAlertController(title: "Game Over", message: "Hai colpito un ostacolo!", preferredStyle: .alert)
        
        // Modifica il colore del titolo e del messaggio
        let titleFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.red]
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        
        let titleAttrString = NSAttributedString(string: "Game Over", attributes: titleFont)
        let messageAttrString = NSAttributedString(string: "Hai colpito un ostacolo!", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        // Aggiungi i pulsanti
        alert.addAction(UIAlertAction(title: "Riprova", style: .default) { _ in
            self.restartGame()
        })
        alert.addAction(UIAlertAction(title: "Esci", style: .cancel) { _ in
            self.showStartScreen()
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }


    // Aggiunge un pulsante di stop del gioco
    func addStopButton() {
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.frame = CGRect(x: self.view.frame.width - 80, y: 40, width: 60, height: 30)
        stopButton.addTarget(self, action: #selector(stopGame), for: .touchUpInside)
        self.view.addSubview(stopButton)
    }

    // Funzione per fermare il gioco quando si preme il pulsante di stop
    @objc func stopGame() {
        gameStopped = true
        playerNode.removeAllActions()
        showGameOverPopup() // Mostra il popup di Game Over come fine anticipata
    }

    // Riavvia il gioco resettando la scena
    func restartGame() {
        gameStopped = false
        gameCompleted = false
        
        // Resetta la posizione del player e velocità iniziale
        playerNode.position = SCNVector3(0, 0.25, 0)
        moveSpeed = 0.1  // Velocità iniziale
        
        // Rimuovi tutte le azioni correnti
        playerNode.removeAllActions()
        
        // Rimuovi ostacoli esistenti e aggiungi nuovi
        scnView.scene?.rootNode.childNodes
            .filter { $0.name == "obstacle" }
            .forEach { $0.removeFromParentNode() }
        
        addObstacles(to: scnView.scene!)
        
        // Avvia il movimento e gli incrementi di velocità e ostacoli
        movePlayer()
        increaseSpeedOverTime()
        increaseObstaclesOverTime()
    }

  }

// Estensione per calcolare la distanza tra due SCNVector3
extension SCNVector3 {
    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
}
