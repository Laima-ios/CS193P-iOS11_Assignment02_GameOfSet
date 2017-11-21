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

	@IBOutlet weak var drawCardsButton: UIButton! {  didSet { setupButtons() } }
	@IBOutlet weak var hintButton: UIButton!  {  didSet { setupButtons() } }
	@IBOutlet weak var newGameButton: UIButton! {  didSet { setupButtons() } }
	
	func setupButtons() {
		hintButton.layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		hintButton.layer.borderWidth = LayOutMetricsForCardView.borderWidthForDrawButton
		hintButton.layer.borderColor = LayOutMetricsForCardView.borderColorForDrawButton
	}
	
	var selectedButtons = [SetCardButton]() {
		willSet(willSelectedButtons) {
			if willSelectedButtons == [] {
				for button in selectedButtons {
					button.stateOfSetCard = .unselected
				}
				if thereIsASet {
					_ = drawCards()
					thereIsASet = false
				}
			} else if willSelectedButtons.count == 3 {
				let indices = willSelectedButtons.map { $0.cardIndex }
				let cards = cardsFor(cardIndices: indices)
				if gameEngine.ifSetThenRemoveFromTable(cards: cards) {
					_ = willSelectedButtons.map { $0.stateOfSetCard = .selectedAndMatched }
					thereIsASet = true
				}
			}
		}
	}
	
	@IBOutlet weak var scoreLabel: UILabel!
	
	var thereIsASet: Bool = false {
		didSet {
			// setScore
		}
	}
	
	@IBAction func onCardButton(_ sender: SetCardButton) {
		if selectedButtons.count == 3  { selectedButtons = [] }
		if sender.cardIndex == 0  { return }
		
		switch sender.stateOfSetCard {
		case .unselected:
			sender.stateOfSetCard = .selected
			selectedButtons.append(sender)
		case .selected:
			if let index = selectedButtons.index(of: sender) {
				sender.stateOfSetCard = .unselected
				selectedButtons.remove(at: index)
			}
		default: break
		}
	}
	
	@IBAction func onDrawCardButton(_ sender: UIButton) {
		guard !thereIsASet else	{
			selectedButtons = []
			return
		}
		_ = drawCards()
	}
	
	@IBAction func onHintButton(_ sender: UIButton) {
		
	}
	
	func drawCards() -> Bool {
		let freeSlotsCount = cardButtons.count - gameEngine.cardsOnTable.count
		guard freeSlotsCount >= 3, let cards = gameEngine.drawCards()  else { return false }
		
		var freeSlots: [SetCardButton] = []
		if thereIsASet {
			freeSlots = selectedButtons
		} else {
			for cardButton in cardButtons {
				if cardButton.cardIndex == 0 {
					freeSlots.append(cardButton)
				}
			}
		}
		for index in cards.indices {
			print("Index: \(index)")
			let attributedString = attributedStringFor(cards[index])
			let setCardButton = freeSlots[index]
			setCardButton.setAttributedTitle(attributedString, for: .normal)
			setCardButton.cardIndex = cards[index].hashValue
		}
		return true
	}
	
	func attributedStringFor(_ card: CardForGameOfSet) -> NSAttributedString {
	
		let shape: String = ModelToView.shapes[card.shape]!
		var returnString: String
		
		switch card.number {
		case .one: returnString = shape
		case .two: returnString = shape + "\n" + shape
		case .three: returnString = shape + "\n" + shape + "\n" + shape
		}
		
		// objective here is to 'compress' the praragraph lines... 
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineHeightMultiple = 0.83

		let attributes: [NSAttributedStringKey : Any] = [
			.strokeColor: ModelToView.colors[card.color]!,
			.strokeWidth: ModelToView.strokeWidth[card.fill]!,
			.foregroundColor: ModelToView.colors[card.color]!.withAlphaComponent(ModelToView.alpha[card.fill]!),
			.paragraphStyle: paragraphStyle
		]
		
		return NSAttributedString(string: returnString, attributes: attributes)
	}
	
	// buttons.cardIndex -> card
	private func cardsFor(cardIndices: [Int]) -> [CardForGameOfSet] {
		var cards = [CardForGameOfSet]()
		for hashValue in cardIndices {
			if let card = (gameEngine.cardsOnTable.filter { $0.hashValue == hashValue }).first {
				cards.append(card)
			}
		}
		return cards
	}
	
	let gameEngine = EngineForGameOfSet()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let cardsOnTable = gameEngine.cardsOnTable
		
		for index in cardsOnTable.indices {
			let attributedString = attributedStringFor(cardsOnTable[index])
			let setCardButton = cardButtons[index]
			setCardButton.setAttributedTitle(attributedString, for: .normal)
			setCardButton.cardIndex = cardsOnTable[index].hashValue
		}

		print("gameEngine: \n\(gameEngine)")
//		print("NoOfElements: \(m.deck.cards.count)\n", m)
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
	static var borderWidthIfSelected: CGFloat = 2.0
	static var borderColorIfSelected: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
	
	static var borderWidthIfMatched: CGFloat = 4.0
	static var borderColorIfMatched: CGColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
	
	static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderWidthForDrawButton: CGFloat = 3.0
	static var cornerRadius: CGFloat = 8.0
}
