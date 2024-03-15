//
//  CoursesViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit

class CoursesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        // Do any additional setup after loading the view.
        print(parse(data: self.data ))
    }
    
    let data = "{\"AudioHostUrl\":\"462bfe0fe6c62b352454f82ebdc0b77b.k.m3.ue1.app.chime.aws:3478\",\"AudioFallbackUrl\":\"wss://haxrp.m3.ue1.app.chime.aws:443/calls/73660de1-f107-4732-acfc-309c6b4c2713\",\"SignalingUrl\":\"wss://signal.m3.ue1.app.chime.aws/control/73660de1-f107-4732-acfc-309c6b4c2713\",\"TurnControlUrl\":\"https://2713.cell.us-east-1.meetings.chime.aws/v2/turn_sessions\",\"ScreenDataUrl\":\"wss://bitpw.m3.ue1.app.chime.aws:443/v2/screen/73660de1-f107-4732-acfc-309c6b4c2713\",\"ScreenViewingUrl\":\"wss://bitpw.m3.ue1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=73660de1-f107-4732-acfc-309c6b4c2713\",\"ScreenSharingUrl\":\"wss://bitpw.m3.ue1.app.chime.aws:443/v2/screen/73660de1-f107-4732-acfc-309c6b4c2713\",\"EventIngestionUrl\":\"https://data.svc.ue1.ingest.chime.aws/v1/client-events\"}"
    
    
}





