//
//  SideNavNoticesView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideNavNoticesCell: UITableViewCell {
    let noticeStackView: UIStackView
    let updatesTextView: UITextView
    private var noticeNumber = 0
    private var notices: Array<Dictionary<String,String>> = [[:]]
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        noticeStackView = UIStackView()
        updatesTextView = UITextView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        contentView.addSubview(noticeStackView)
        
        noticeStackView.axis = .horizontal
        noticeStackView.spacing = 5
        noticeStackView.alignment = .fill
        noticeStackView.distribution = .fillEqually
        noticeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noticeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noticeStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            noticeStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let nextNoticeBtn = UIButton()
        nextNoticeBtn.addTarget(self, action: #selector(showNextNotice), for: .touchUpInside)
        setButtonBgImage(button: nextNoticeBtn, bgImage: singleRightIcon, tintColor: .white)
        setBtnImgProp(button: nextNoticeBtn, topPadding: 5, leftPadding: 5)
        nextNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let prevNoticeBtn = UIButton()
        prevNoticeBtn.addTarget(self, action: #selector(showPrevNotice), for: .touchUpInside)
        setButtonBgImage(button: prevNoticeBtn, bgImage: singleLeftIcon, tintColor: .white)
        setBtnImgProp(button: prevNoticeBtn, topPadding: 5, leftPadding: 5)
        prevNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        noticeStackView.insertArrangedSubview(prevNoticeBtn, at: 0)
        noticeStackView.insertArrangedSubview(nextNoticeBtn, at: 1)
        
        let noticeLbl = UILabel()
        noticeLbl.text = "Notice"
        noticeLbl.textColor = .white
        noticeLbl.backgroundColor = .clear
        noticeLbl.textAlignment = .center
        noticeStackView.insertArrangedSubview(noticeLbl, at: 1)
        noticeLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeLbl.topAnchor.constraint(equalTo: noticeStackView.topAnchor),
            noticeLbl.bottomAnchor.constraint(equalTo: noticeStackView.bottomAnchor)
        ])
        
        updatesTextView.isEditable = false
        updatesTextView.textColor = .white
        updatesTextView.backgroundColor = .clear
        updatesTextView.font = getFont(name: .HelveticaNeue, size: .medium)
        showNotice()
        
        updatesTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(updatesTextView)
        
        NSLayoutConstraint.activate([
            updatesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            updatesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            updatesTextView.topAnchor.constraint(equalTo: noticeStackView.bottomAnchor),
            updatesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        //        updatesTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        contentView.addBottomBorder(with: .darkGray, andWidth: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Actions

extension SideNavNoticesCell {
    @objc func showNextNotice() {
        if noticeNumber - 1 >= 0 {
            noticeNumber -= 1
        }
        showNotice()
    }
    
    @objc func showPrevNotice() {
        if noticeNumber + 1 < notices.count {
            noticeNumber += 1
        }
        showNotice()
    }
    
    func showNotice() {
        if noticeNumber >= 0 && noticeNumber < notices.count {
            
            guard let date = notices[noticeNumber]["date"],let notice = notices[noticeNumber]["notice"] else {
                updatesTextView.text = "No notices..."
                return
            }
            
            updatesTextView.text = "\(notice)\n\n\(date)"
            
        } else {
            updatesTextView.text = "No notices..."
        }
        
    }
    
    func fetchNotices() {
        
        let notesFIRBRef = Database.database().reference().child("notices")
        notesFIRBRef.keepSynced(true)
        notesFIRBRef.observe(.value) { (snapshot) in
            guard var notices = snapshot.value as? Array<Dictionary<String,String>> else { return }
            
            notices = notices.sorted(by: {(arg0,arg1) in
                guard let date1 = arg0["date"], let date2 = arg1["date"] else { return false}
                guard let dateObj1 = convertToDate(date: date1), let dateObj2 = convertToDate(date: date2) else { return false }
                return dateObj1 > dateObj2
            })
            self.notices = notices
            self.showNotice()
        }
    }
}
