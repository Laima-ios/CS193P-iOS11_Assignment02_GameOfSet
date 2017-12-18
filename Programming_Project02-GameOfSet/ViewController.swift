//
//  ViewController.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

	@IBOutlet var cardButtons: [SetCardButton]!
	
	@IBOutlet weak var drawCardsButton: UIButton! {
		didSet {
			layOutFor(drawCardsButton)
			drawCardsButton!.titleLabel?.numberOfLines = 0
			drawCardsButton.setTitle("none", for: .disabled)
		}
	}
	@IBOutlet weak var hintButton: UIButton! { didSet { layOutFor(hintButton) } }
	@IBOutlet weak var startNewGameButton: UIButton! { didSet { layOutFor(startNewGameButton) } }
	@IBOutlet weak var scoreLabel: UILabel! { didSet { layOutFor(scoreLabel) } }

	
	func layOutFor(_ view: UIView) {
		view.layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		view.layer.borderWidth = LayOutMetricsForCardView.borderWidthForDrawButton
		view.layer.borderColor = LayOutMetricsForCardView.borderColorForDrawButton
		view.clipsToBounds = true
	}
	
	private var gameEngine: EngineForGameOfSet! {
		didSet {
			let cardsOnTable = gameEngine.cardsOnTable
			hints.cards = gameEngine.hints
			cardsOnTable.indices.forEach { cardButtons[$0].card = cardsOnTable[$0] }
		}
	}

	private var selectedButtons: [SetCardButton] {
		return cardButtons.filter { cardView in
			cardView.stateOfSetCardButton == .selected || cardView.stateOfSetCardButton == .selectedAndMatched
		}
	}
	
	private var thereIsASet: Bool {
		let cards = selectedButtons.filter { $0.card != nil }.map { $0.card! }
		if cards.count == 3 && gameEngine.isSet(cards: cards) {
			selectedButtons.forEach { $0.stateOfSetCardButton = .selectedAndMatched }
			drawCardsButton.isEnabled = true
			return true
		}
		return false
	}
	
	private func handleSetState() {
		let cards = selectedButtons.map { $0.card! }
		if cards.count == 3 && gameEngine.ifSetThenRemoveFromTable(cards: cards) {
			hints.cards = gameEngine.hints
			scoreLabel.text = "\(gameEngine.score)"
			selectedButtons.forEach {
				$0.card = nil
			}
		}
	}

	@IBAction func onCardButton(_ sender: SetCardButton) {
		if selectedButtons.count == 3  {
			if thereIsASet {
				return
			}
			selectedButtons.forEach { $0.stateOfSetCardButton = .unselected }
		}
		sender.stateOfSetCardButton = sender.stateOfSetCardButton == .selected ? .unselected : .selected
		if thereIsASet {
			return
		}
	}
	
	@IBAction func onDrawCardButton(_ sender: UIButton) {
		if thereIsASet {
			handleSetState()
			drawCardsButton.isEnabled = gameEngine.deckCount >= 3
		}
		let freeSlotsCount = cardButtons.count - gameEngine.cardsOnTable.count
		if freeSlotsCount >= 3, let cards = gameEngine.drawCards() {
			var freeSlots: [SetCardButton] = thereIsASet ? selectedButtons: cardButtons.filter { $0.cardIndex == 0 }
			for index in cards.indices {
				let setCardButton = freeSlots[index]
				setCardButton.card = cards[index]
				hints.cards = gameEngine.hints
			}
		} else {
			drawCardsButton.isEnabled = false
		}
	}

	@IBAction func onNewGameButton(_ sender: UIButton) {
		cardButtons.forEach {
			$0.card = nil
		}
		cardButtons.forEach { $0.card = nil }
		gameEngine = EngineForGameOfSet()
		drawCardsButton.isEnabled = true
	}
	
	private var hints: (cards: [[CardForGameOfSet]], index: Int) = ([[]], 0) {
		didSet {
			if hints.index == oldValue.index {
				hints.index = 0
			}
			hintButton!.isEnabled = !hints.cards.isEmpty ? true : false
			hintButton!.setTitle("hints: \(hints.cards.count)", for: .normal)
		}
	}

	private var timer: Timer?
	private var _lastHint: [SetCardButton]?
	
	@IBAction func onHintButton(_ sender: UIButton) {
		timer?.invalidate()
		_lastHint?.forEach { $0.stateOfSetCardButton = .unselected }
		selectedButtons.forEach { $0.stateOfSetCardButton = .unselected }
		let cardButtonsWithSet = buttonsFor(cards: hints.cards[hints.index])
		cardButtonsWithSet.forEach { $0.stateOfSetCardButton = .hinted  }
		_lastHint = cardButtonsWithSet
		hints.index = hints.index < hints.cards.count - 1 ? hints.index + 1 : 0
		timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {  timer in
			cardButtonsWithSet.forEach { [weak self] in
				if $0.stateOfSetCardButton == .hinted {
					$0.stateOfSetCardButton = .unselected
					self?._lastHint = nil
				}
			}
		}
	}
	
	private func cardsFor(cardIndices: [Int]) -> [CardForGameOfSet] {
		var cards = [CardForGameOfSet]()
		for hashValue in cardIndices {
			if let card = (gameEngine.cardsOnTable.filter { $0.hashValue == hashValue }).first {
				cards.append(card)
			}
		}
		return cards
	}
	
	private func buttonsFor(cards: [CardForGameOfSet])-> [SetCardButton] {
		var buttons: [SetCardButton] = []
		for card in cards {
			if let button = (cardButtons.filter { $0.cardIndex == card.hashValue }).first  {
				buttons.append(button)
			}		
		}
		return buttons
	}

	
	override func viewDidLoad() {
		super.viewDidLoad()
		gameEngine = EngineForGameOfSet()
	}
}

struct ModelToView {
	static let shapes: [CardForGameOfSet.Shapes: String] = [.circle: "●", .triangle: "▲", .square: "■"]
	static var colors: [CardForGameOfSet.Colors: UIColor] = [.red: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), .blue: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), .green: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
	static var alpha: [CardForGameOfSet.Fills: CGFloat] = [.solid: 1.0, .empty: 0.40, .stripe: 0.15]
	static var strokeWidth: [CardForGameOfSet.Fills: CGFloat] = [.solid: -5, .empty: 5, .stripe: -5]
}

struct LayOutMetricsForCardView {
	static var borderWidth: CGFloat = 1.0
	static var borderWidthIfSelected: CGFloat = 3.0
	static var borderColorIfSelected: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
	
	
	static var borderWidthIfHinted: CGFloat = 4.0
	static var borderColorIfHinted: CGColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1).cgColor
	
	static var borderWidthIfMatched: CGFloat = 4.0
	static var borderColorIfMatched: CGColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
	
	static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderWidthForDrawButton: CGFloat = 3.0
	static var cornerRadius: CGFloat = 8.0
}
