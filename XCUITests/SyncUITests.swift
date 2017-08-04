/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class SyncUITests: BaseTestCase {
    
    var navigator: Navigator!
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        navigator = createScreenGraph(app).navigator(self)
    }
    
    override func tearDown() {
        navigator = nil
        app = nil
        super.tearDown()
    }

    func skipIntro() {
        let startBrowsingButton = app.buttons["IntroViewController.startBrowsingButton"]
        let introScrollView = app.scrollViews["IntroViewController.scrollView"]
        introScrollView.swipeLeft()
        startBrowsingButton.tap()
    }
    
    func signIn() {
        navigator.goto(SettingsScreen)
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Sign In to Firefox"].tap()
        waitforExistence(app.buttons["Sign in"])
        
        //Only for the first time it browser will ask for email address entry
        let emailTextField = app.textFields["Email"]
        if emailTextField.exists {
            app.textFields["Email"].tap()
            app.textFields["Email"].typeText("mozillafirfox61@gmail.com")
        }
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("mozillafirfox611")
        app.buttons["Sign in"].tap()
        
        sleep(1)
        app.tap()
        
        sleep(2)
        let settingsBackButton = app.navigationBars["Homepage Settings"].buttons["Settings"]
        if settingsBackButton.exists {
            settingsBackButton.tap()
        }
        
        //Delay for syncing the data from synced devices
        sleep(10)
        waitforExistence(app.staticTexts["Sync Now"])
        app.buttons["Done"].tap()
    }
    
    func testSyncHistory() {
        //Navigate to browser screen
        skipIntro()
        
        //Open history tab
        waitforExistence(app.buttons["HomePanels.History"])
        app.buttons["HomePanels.History"].tap()
        
        //Cell count should be 2 before sync
        let count = UInt(app.tables["History List"].cells.allElementsBoundByIndex.count)
        XCTAssertTrue(count == 2, "Websites you've visited recently will show up here.")
        
        //Open Topsites tab
        app.buttons["HomePanels.TopSites"].tap()
        
        //Sign in to fetch synced devices history
        signIn()
        
        //Open history tab
        app.buttons["HomePanels.History"].tap()
        
        //Cell count should be more than 2 after sync
        let visibleCells = UInt(app.tables["History List"].cells.allElementsBoundByIndex.count)
        XCTAssertTrue(visibleCells > 2)
    }
    
    func testSyncBookmarks() {
        //Navigate to browser screen
        skipIntro()
        
        //Open bookmarks tab
        waitforExistence(app.buttons["HomePanels.Bookmarks"])
        app.buttons["HomePanels.Bookmarks"].tap()
        
        //Cell count should be 0 before sync
        let count = UInt(app.tables["Bookmarks List"].cells.allElementsBoundByIndex.count)
        XCTAssertTrue(count == 0, "No bookmarks")
        
        //Open Topsites tab
        app.buttons["HomePanels.TopSites"].tap()
        
        //Sign in to fetch synced devices bookmarks
        signIn()
        
        //Open bookmarks tab
        app.buttons["HomePanels.Bookmarks"].tap()
        
        app.tables["Bookmarks List"].staticTexts["Desktop Bookmarks"].tap()
        app.tables["Bookmarks List"].staticTexts["Unsorted Bookmarks"].tap()
        XCTAssertTrue(app.staticTexts["Apple"].exists, "Apple")
    }
}
