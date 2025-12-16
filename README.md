# DustJourney

DustJourney è un semplice prototipo di gioco endless runner 3D sviluppato con **SceneKit** per iOS.

## Caratteristiche
- Interfaccia iniziale con pulsanti **Start** e **Login** (quest'ultimo mostra un popup con campi utente e password e stampa le credenziali in console).
- Scena 3D con strada, player cubico rosso, luce omnidirezionale e telecamera dall'alto che segue il movimento.
- Movimento continuo in avanti del player con incremento progressivo della velocità e aggiunta di nuovi ostacoli nel tempo.
- Controlli tramite swipe laterali per cambiare corsia e pulsante "Stop" per terminare prematuramente la partita.
- Rilevamento collisioni con popup di **Game Over** e popup di completamento al termine del percorso, entrambi con opzioni di restart o uscita al menu iniziale.

## Requisiti
- Xcode 15+ (progetto iOS SceneKit).
- iOS 15+ come target di esecuzione consigliato.

## Esecuzione
1. Apri `DustJourney.xcodeproj` in Xcode.
2. Seleziona un simulatore o un dispositivo iOS e avvia il build/run (⌘+R).
3. Tocca **Start** per iniziare la partita oppure **Login** per aprire il popup dimostrativo.

> Nota: Questo repository è pubblico. Nell'ambiente corrente non è disponibile la toolchain iOS, quindi il comportamento runtime non è stato verificato qui.
