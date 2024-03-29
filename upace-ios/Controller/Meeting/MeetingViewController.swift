//
//  MeetingViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 13/03/24.
//

import UIKit
import AmazonChimeSDK
import AVFoundation
import AWSCore

class MeetingViewController: UIViewController, UIGestureRecognizerDelegate {

    
    private var isMute = false
    private var isLocalVideoStarted = false
    private var sideMenuWidth : CGFloat = 300
    private var isSideMenuShowing =  false
    
    var meetingSession: MeetingSession?
    
    private var joinData : JoinInfoResponse?
    private var mediaPlacementData : MediaPlacementResponse?
    
    var defaultVideoRenderView = DefaultVideoRenderView()
    var previewRenderView = DefaultVideoRenderView()
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var localVideoView: UIView!
    
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var boothNameLabel: UILabel!
    
    @IBOutlet weak var sideMenuButtonView: UIView!
    @IBOutlet weak var dotsButtonView: UIView!
    @IBOutlet weak var noStudentQueueLabel: UILabel!
    
    
    
    //side queue outlets
    @IBOutlet weak var sideQueueView: CustomView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuLeadingConstraint: NSLayoutConstraint!
    
    //MARK: View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        LOG("\(type(of: self)) viewDidLoad")
    
        initializeScreen()
        sideViewSetup()
        getJoinData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        defaultVideoRenderView = DefaultVideoRenderView(frame: videoView.frame)
        defaultVideoRenderView.contentMode = .scaleAspectFit
        self.videoView.addSubview(defaultVideoRenderView)
        self.videoView.bringSubviewToFront(defaultVideoRenderView)
        
        previewRenderView = DefaultVideoRenderView(frame: localVideoView.frame)
        previewRenderView.contentMode = .scaleAspectFit

        previewRenderView.frame.origin.y = 0
        previewRenderView.frame.origin.x = 0

        self.localVideoView.addSubview(previewRenderView)
        self.localVideoView.bringSubviewToFront(previewRenderView)
        

    }

    //MARK: IBActions
    @IBAction func flipButtonAction(_ sender: Any) {
        guard let meetingSession = self.meetingSession else {
            return
        }
        
        meetingSession.audioVideo.switchCamera()
        
        // Add logic to respond to camera type change.
        switch meetingSession.audioVideo.getActiveCamera()?.type {
        case .videoFrontCamera:
            // Handle logic for front camera
            print("Switched to front camera")
        case .videoBackCamera:
            // Handle logic for back camera
            print("Switched to back camera")
        default:
            // Handle other camera types if needed
            print("Unknown camera type")
        }
        
    }
    
    
    @IBAction func micButtonAction(_ sender: Any) {
        toggleMic()
    }
    

    @IBAction func videoButtonAction(_ sender: Any) {
        toggleVideo()
    }
    
    
    @IBAction func speakerButtonAction(_ sender: Any) {
        
    }
 
    
    @IBAction func callButtonAction(_ sender: Any) {
        callCut()
    }
    
    
    @IBAction func sideMenuAction(_ sender: Any) {
        showSideMenu(duration: 0.3)
    }
    
    
    @IBAction func dotsAction(_ sender: Any) {
        
    }
    
    //MARK: Functions
    
    
    private func initializeScreen(){
        boothNameLabel.text = Singleton.shared.currentJoinMeeting?.data?.university_name
        
        // Set up callback from FirebaseManager
        FirebaseManager.shared.meetingActionCallback = { [weak self] meetingResponse in
            // Handle different actions based on meeting response
            if meetingResponse.title == "muteAttendee" {
                if !(self?.isMute ?? true){
                    self?.toggleMic()
                }
            } else if meetingResponse.title == "stopVideoAttendee" {
                if (self?.isLocalVideoStarted ?? false){
                    self?.toggleVideo()
                }
            } else if meetingResponse.title == "removeAttendee"{
                self?.callCut()
            }
        }
    }
    
    private func toggleMic(){
        guard let meetingSession = self.meetingSession else {
            return
        }
        
        if isMute {
            if meetingSession.audioVideo.realtimeLocalUnmute(){
                isMute = false
                micImageView.image = UIImage(named: "mic")
            }
        }else{
            if meetingSession.audioVideo.realtimeLocalMute(){
                isMute = true
                micImageView.image = UIImage(named: "mute")
            }
        }
    }
    
    
    private func toggleVideo(){
        guard let meetingSession = self.meetingSession else {
            return
        }
        if isLocalVideoStarted {
            meetingSession.audioVideo.stopLocalVideo()
            isLocalVideoStarted = false
            videoImageView.image = UIImage(named: "videoOff")
        }else{
            do{
                try meetingSession.audioVideo.startLocalVideo()
                isLocalVideoStarted = true
                videoImageView.image = UIImage(named: "videoOn")
            }catch{
                print("Error in starting local video")
            }
        }
    }
    
    
    private func callCut(){
        if let meetingSession = self.meetingSession  {
            meetingSession.audioVideo.stop()
        }
        
        self.dismiss(animated: false)
        self.navigationController?.popViewController(animated: false)
        
        FirebaseManager.shared.delegate?.queueUpdated()
        
        let meetingData = Singleton.shared.currentJoinMeeting
        //mark meeting as completed..
        param = [
            "counsellor_id": meetingData?.data?.counsellor_id ?? "",
            "event_id": meetingData?.data?.event_id ?? "",
            "status": "completed",
            "user_id": meetingData?.data?.user?.user_external_id ?? ""
        ]
        
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_QUEUE + "/user" , method: .patch , parameter: param, objectClass: LoginResponse.self, requestCode: U_QUEUE) { response in
            guard response != nil else{
                LOG("Error in getting response")
                return
            }
            
            FirebaseManager.shared.delegate?.queueUpdated()
            FirebaseManager.shared.sendNotification(type: "deleteQueue", queueData: nil, meetingData: meetingData?.data)
            
            Singleton.shared.currentJoinMeeting = nil
            
        }
        
    }
    
    
    func getJoinData(){
        
        let meetingData = Singleton.shared.currentJoinMeeting?.data
        
        let universityId = meetingData?.university_id ?? ""
        let eventId = meetingData?.event_id ?? ""
        let counsellorId = meetingData?.counsellor_id ?? ""
   
        let url = U_BASE + U_MEETING + "/" + universityId + "?event_id=" + eventId + "&counsellor_id=" + counsellorId
        
        LOG("📅🖥️ Meeting URL : \(url)")
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: JoinInfoResponse.self, requestCode: U_EVENT) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
           
            self.joinData = response
            
            print("🟢joinData \(String(describing: self.joinData))")
            self.mediaPlacementData = parseMediaData(data: self.joinData?.data?.JoinInfo?.Meeting?.MediaPlacement ?? "")
            
            print("🟢mediaPlacementData \(String(describing: self.joinData))")
            
            self.requestMicrophoneAndCameraPermissions { microphoneGranted, cameraGranted in
                
                print("microphoneGranted \(microphoneGranted)")
                print("cameraGranted \(cameraGranted)")
                if microphoneGranted && cameraGranted {
                    
                    self.setupAmazonVideoCall()
                    // Both microphone and camera permissions granted, proceed with using audio and video
                } else {
                    // Handle the case where either or both permissions are denied
                }
            }
        }
    }
    
    
    
    
    // Function to request microphone and camera permissions
    func requestMicrophoneAndCameraPermissions(completion: @escaping (Bool, Bool) -> Void) {
        var microphoneGranted = false
        var cameraGranted = false
        
        // Request microphone permission
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            // Microphone permission granted
            microphoneGranted = true
        case .denied, .undetermined:
            // Microphone permission denied or not determined yet, request permission
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                microphoneGranted = granted
                checkPermissionsAndComplete()
            }
        @unknown default:
            break
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            cameraGranted = granted
            checkPermissionsAndComplete()
        }
        
        
        func checkPermissionsAndComplete() {
            if microphoneGranted && cameraGranted {
                completion(true, true)  // Both microphone and camera permissions granted
            } else if !microphoneGranted && cameraGranted {
                completion(false, true)  // Microphone permission denied, camera permission granted
            } else if microphoneGranted && !cameraGranted {
                completion(true, false)  // Microphone permission granted, camera permission denied
            } else {
                completion(false, false)  // Both microphone and camera permissions denied
            }
        }
    }
    


    
    
    
    func setupAmazonVideoCall(){
        
        guard let joinData = joinData?.data?.JoinInfo else{
            LOG("Not Getting Join data")
            return
        }
        
        guard let mediaData = mediaPlacementData else {
            LOG("Not Getting media data")
            return
        }
        
        print("Data parsed successfully 🟢")
        
        let mediaPlacement = MediaPlacement(audioFallbackUrl: mediaData.audioFallbackUrl , audioHostUrl: mediaData.audioHostUrl, signalingUrl: mediaData.signalingUrl, turnControlUrl: mediaData.turnControlUrl, eventIngestionUrl: mediaData.eventIngestionUrl )
        
        let meeting = Meeting(externalMeetingId: joinData.Meeting?.ExternalMeetingId, mediaPlacement: mediaPlacement, mediaRegion: joinData.Meeting!.MediaRegion, meetingId: joinData.Meeting!.MeetingId)
        
        let myCreatemeetingresponse = CreateMeetingResponse(meeting: meeting)
        
        
        let attendee = Attendee(attendeeId: joinData.Attendee!.AttendeeId , externalUserId: joinData.Attendee!.ExternalUserId, joinToken: joinData.Attendee!.JoinToken)
        let myCreateAttendeeResponse = CreateAttendeeResponse(attendee: attendee)

        
        let meetingConfig = MeetingSessionConfiguration(createMeetingResponse: myCreatemeetingresponse, createAttendeeResponse: myCreateAttendeeResponse)
        
        
        // 2. Initialize the Meeting Session
        let logger = ConsoleLogger(name: "MeetingViewController")
        meetingSession = DefaultMeetingSession(configuration: meetingConfig, logger: logger)
        
        
        // 3. Staring meeting seesion
        do {
            try self.meetingSession?.audioVideo.start()
            print("🟢Succes in start")
        } catch PermissionError.audioPermissionError {
            print("PermissionError.audioPermissionError")
            // Handle the case where no permission is granted.
            return
        } catch {
            print("Catch other errors.")
            // Catch other errors.
            return
        }
        
        // Start local video.
        do {
            try self.meetingSession?.audioVideo.startLocalVideo()
            isLocalVideoStarted = true
            print("🟢Succes in start ocal video")
        } catch PermissionError.videoPermissionError {
            print("PermissionError.videoPermissionError")
            // Handle the case where no permission is granted.
        } catch {
            print("other error in local video")
            // Catch some other errors.
        }
        
        guard let meetingSession = self.meetingSession else {
            return
        }
        
        //start audio
        if meetingSession.audioVideo.realtimeLocalUnmute(){
            isMute = false
            DispatchQueue.main.async{
                self.micImageView.image = UIImage(named: "mic")
            }
            
        }else{
            isMute = true
            DispatchQueue.main.async{
                self.micImageView.image = UIImage(named: "mute")
            }
        }

     
        // Start remote video.
        meetingSession.audioVideo.startRemoteVideo()
        
        
        //4. resister observer
        // Register observer.
//        self.meetingSession?.audioVideo.addAudioVideoObserver(observer: self)
//        self.meetingSession?.audioVideo.addRealtimeObserver(observer: self)
        self.meetingSession?.audioVideo.addVideoTileObserver(observer: self)
        
    }
    

    
}





//MARK: Meeting Observer

extension MeetingViewController: AudioVideoObserver {
    func audioSessionDidStartConnecting(reconnecting: Bool) {
        LOG("🖥️audioSessionDidStartConnecting")
    }
    
    func audioSessionDidStart(reconnecting: Bool) {
        LOG("🖥️audioSessionDidStart \(reconnecting)")
    }
    
    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("🖥️audioSessionDidStopWithStatus \(sessionStatus)")
    }
    
    func audioSessionDidCancelReconnect() {
        LOG("🖥️audioSessionDidCancelReconnect")
    }
    
    func connectionDidRecover() {
        LOG("🖥️connectionDidRecover")
    }
    
    func connectionDidBecomePoor() {
        LOG("🖥️connectionDidBecomePoor")
    }
    
    func videoSessionDidStartConnecting() {
        LOG("🖥️videoSessionDidStartConnecting")
    }
    
    func videoSessionDidStartWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("🖥️videoSessionDidStartWithStatus \(sessionStatus)")
    }
    
    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("🖥️videoSessionDidStopWithStatus \(sessionStatus)")
    }
    
    func audioSessionDidDrop() {
        LOG("🖥️audioSessionDidDrop")
    }
    
    func remoteVideoSourcesDidBecomeAvailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        LOG("🖥️audioSessionDidStartConnecting")
    }
    
    func remoteVideoSourcesDidBecomeUnavailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        LOG("🖥️remoteVideoSourcesDidBecomeAvailable \(sources)")
    }
    
    func cameraSendAvailabilityDidChange(available: Bool) {
        LOG("🖥️cameraSendAvailabilityDidChange \(available)")
    }
    
}



extension MeetingViewController: RealtimeObserver {
    func volumeDidChange(volumeUpdates: [AmazonChimeSDK.VolumeUpdate]) {
        LOG("🔊volumeDidChange \(volumeUpdates)")
    }
    
    func signalStrengthDidChange(signalUpdates: [AmazonChimeSDK.SignalUpdate]) {
        LOG("🔊signalStrengthDidChange \(signalUpdates)")
    }
    
    func attendeesDidJoin(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("🔊attendeesDidJoin \(attendeeInfo)")
    }
    
    func attendeesDidLeave(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("🔊attendeesDidLeave \(attendeeInfo)")
    }
    
    func attendeesDidMute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("🔊attendeesDidMute \(attendeeInfo)")
    }
    
    func attendeesDidUnmute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("🔊attendeesDidUnmute \(attendeeInfo)")
    }
    
    func attendeesDidDrop(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("🔊attendeesDidDrop \(attendeeInfo)")
    }
    
    
}



extension MeetingViewController: VideoTileObserver {
    func videoTileSizeDidChange(tileState: AmazonChimeSDK.VideoTileState) {
        LOG("📀videoTileSizeDidChange \(tileState)")
        
//        // Bind video tile.
//        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
    
    func videoTileDidAdd(tileState: VideoTileState) {
        LOG("🟢📀videoTileDidAdd \(tileState)")
        
        if tileState.isLocalTile{
            self.meetingSession?.audioVideo.bindVideoView(videoView: previewRenderView, tileId: tileState.tileId )
        }else{
            self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
        }
    }
    func videoTileDidRemove(tileState: VideoTileState) {
        LOG("🔴📀videoTileDidRemove \(tileState)")
        
        if tileState.isLocalTile{
            previewRenderView.resetImage()
        }else{
            defaultVideoRenderView.resetImage()
        }
 
    }
    func videoTileDidPause(tileState: VideoTileState) {
        LOG("📀videoTileDidPause \(tileState)")
        // Bind video tile.
//        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
    func videoTileDidResume(tileState: VideoTileState) {
        LOG("📀videoTileDidResume \(tileState)")
        // Bind video tile.
//        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
}



//MARK: Side Queue View
extension MeetingViewController  : UITableViewDataSource, UITableViewDelegate {

    private func sideViewSetup(){
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        sideMenuWidth = self.view.frame.width * 0.8
        sideMenuWidthConstraint.constant = sideMenuWidth
        setupSwipeAndTapGestureRecognizers()
        hideSideMenu(duration: 0)
        sideMenuTableView.contentInset.top = 20
        sideQueueView.shadowOpacity = 0
        
        getStudentsInQueue()
    }
    
    func hideSideMenu(duration : TimeInterval){
        self.isSideMenuShowing = false
        UIView.animate(withDuration: duration,animations: {
            self.sideMenuLeadingConstraint.constant = -self.sideMenuWidth
            self.sideQueueView.shadowOpacity = 0
           
            self.view.layoutIfNeeded()
        }){_ in
//            self.darkScreenView.isHidden = true
        }
    }

    
    func showSideMenu(duration : TimeInterval){
        self.isSideMenuShowing = true
        UIView.animate(withDuration: duration) {
            self.sideMenuLeadingConstraint.constant = 0
            self.sideQueueView.shadowOpacity = 0.8
            self.view.layoutIfNeeded()
        }
    }
    
    func setupSwipeAndTapGestureRecognizers() {
        // Swipe Gesture Recognizer
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        swipeGesture.delegate = self
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    // MARK: - Gesture Handling
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if !isSideMenuShowing {return}
        let translationX = gesture.translation(in: self.view).x
        
        switch gesture.state {
        case .changed:
            let totalWidth = view.bounds.width
            let leadingConstant = min(max(CGFloat(-sideMenuWidth), sideMenuLeadingConstraint.constant + translationX), 0)
            sideMenuLeadingConstraint.constant = leadingConstant
            let percentage = (totalWidth - (leadingConstant + sideMenuWidth)) / totalWidth
            self.sideQueueView.shadowOpacity = Float(( 1 - percentage))
            gesture.setTranslation(.zero, in: self.view)
        case .ended:
            let velocityX = gesture.velocity(in: self.view).x
            if velocityX < 0 {
                hideSideMenu(duration: 0.1)
            } else {
                showSideMenu(duration: 0.1)
            }
        default:
            break
        }
    }
    
    func getStudentsInQueue(){
        noStudentQueueLabel.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleUserCell") as! SingleUserCell
        return cell
    }
    
    
}




//MARK: Student Cell
class SingleUserCell : UITableViewCell{
    
    @IBOutlet weak var studentProfileImageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buttonView: CustomView!
    @IBOutlet weak var buttonLabel: UILabel!
    

    @IBAction func joinButtonAction(_ sender: UIButton) {
        
        LOG("Join Button Tapped")
    }
    
    
}
