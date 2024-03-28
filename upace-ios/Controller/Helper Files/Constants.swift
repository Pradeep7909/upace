//
//  Constants.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import Foundation
import UIKit

//MARK: COLORS
var K_BLUE_COLOR = UIColor(red: 46/255, green: 113/255, blue: 255/255, alpha: 1) //#2E71FF


var param = [String:Any]()




//MARK: BASE URLS
let U_BASE = "https://vfair-beta-api.upace.in/api/v1/"
let U_BASE_MAIN = "https://api.upace.in/api/v1/"

let U_SIGNUP = "register"
let U_LOGIN = "auth/login"
let U_EVENT = "v-fair-event"
let U_LATEST = "?type=latest"
let U_EMAIL_SUBSCRIBE = "cms/email-subscribe"
let U_BOOTH_UNIVERSITIES = "/universities?event_id="
let U_MEETING = "v-fair/meeting"
let U_QUEUE = "meeting/queue"


//MARK: USER DEFAULTS
let UD_USER_DETAIL = "userDetail"
let UD_TOKEN = "user_token"
let UD_APP_THEME = "UD_APP_THEME"
