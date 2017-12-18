//
//  SetCardButton.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 21/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

class SetCardButton: UIButton {
	
	var cardIndex: Int = 0
	
	var card: CardForGameOfSet? {
		didSet {
			if let card = card {
				cardIndex = card.hashValue
				stateOfSetCardButton = .unselected
				let attrString = attributedString(for: card)
				setAttributedTitle(attrString, for: .normal)
			} else {
				cardIndex = 0
				setAttributedTitle(NSAttributedString(), for: .normal)
				stateOfSetCardButton = .unselected
			}
		}
	}
	
	private func setBorderLayout () {
		layer.borderWidth = LayOutMetricsForCardView.borderWidth
		layer.borderColor = LayOutMetricsForCardView.borderColor
		layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		titleLabel?.numberOfLines = 0
	}
	
	enum StateOfSetCardButton {
		case unselected
		case selected
		case selectedAndMatched
		case hinted
	}
	
	var stateOfSetCardButton: StateOfSetCardButton = .unselected {
		didSet {
			switch stateOfSetCardButton {
			case .unselected:
				if oldValue == .selectedAndMatched {
					setAttributedTitle(NSAttributedString(), for: .normal)
				}
				layer.borderWidth = LayOutMetricsForCardView.borderWidth
				layer.borderColor = LayOutMetricsForCardView.borderColor
			case .selected:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfSelected
				layer.borderColor = LayOutMetricsForCardView.borderColorIfSelected
			case .selectedAndMatched:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfMatched
				layer.borderColor = LayOutMetricsForCardView.borderColorIfMatched
			case .hinted:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfHinted
				layer.borderColor = LayOutMetricsForCardView.borderColorIfHinted
			}
		}
	}
	
// hmmm...messy
// TODO: Redesign attributedString
	private func attributedString(for card: CardForGameOfSet) -> NSAttributedString {
		let shape: String = ModelToView.shapes[card.shape]!
		var returnString: String
		
		switch card.number {
		case .one: returnString = shape
		case .two: returnString = shape + "\n" + shape
		case .three: returnString = shape + "\n" + shape + "\n" + shape
		}
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineHeightMultiple = 0.80
		
		let attributes: [NSAttributedStringKey : Any] = [
			.strokeColor: ModelToView.colors[card.color]!,
			.strokeWidth: ModelToView.strokeWidth[card.fill]!,
			.foregroundColor: ModelToView.colors[card.color]!.withAlphaComponent(ModelToView.alpha[card.fill]!),
			.paragraphStyle: paragraphStyle
		]
		return NSAttributedString(string: returnString, attributes: attributes)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setBorderLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setBorderLayout()
	}

}
