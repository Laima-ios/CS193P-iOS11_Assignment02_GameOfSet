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
	
	func initialise () {
		layer.borderWidth = LayOutMetricsForCardView.borderWidth
		layer.borderColor = LayOutMetricsForCardView.borderColor
		layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		titleLabel?.numberOfLines = 0
		
	}
	
	enum StateOfSetCard {
		case unselected
		case selected
		case selectedAndMatched
		
	}
	
	var stateOfSetCard: StateOfSetCard = .unselected {
		didSet {
			switch stateOfSetCard {
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
				cardIndex = 0
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialise()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialise()
	}

}
