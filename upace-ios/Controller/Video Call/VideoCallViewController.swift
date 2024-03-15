//
//  VideoCallViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 13/03/24.
//

import UIKit
import AmazonChimeSDK
import AVFoundation
import AWSCore

class VideoCallViewController: UIViewController, UIGestureRecognizerDelegate {

    
    private var isUsingFrontCamera = true
    private var sideMenuWidth : CGFloat = 300
    private var isSideMenuShowing =  false
    let captureSession = AVCaptureSession()
    
    
    var meetingSession: MeetingSession?
    var videoTileController: VideoTileController?
    var remoteVideoView2: DefaultVideoRenderView?
    
    var joinData : JoinInfoResponse?
    var mediaPlacementData : MediaPlacementResponse?
    
    let defaultVideoRenderView = DefaultVideoRenderView(frame: .infinite)
    
    @IBOutlet weak var renderVideoView: DefaultVideoRenderView!
    
//    @IBOutlet weak var renderVideoView: DefaultVideoRenderView!
    
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
        self.view.addSubview(defaultVideoRenderView)
        self.view.bringSubviewToFront(defaultVideoRenderView)
        sideViewSetup()
        
//        addRenderView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        startLocalVideo(camera: .front)
//        getJoinData()
        
        
        getJoinData()
        
    }

    //MARK: IBActions
    @IBAction func flipButtonAction(_ sender: Any) {
        
        let newPosition: AVCaptureDevice.Position = isUsingFrontCamera ? .back : .front
        
        if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
           let newInput = try? AVCaptureDeviceInput(device: newDevice) {
            captureSession.beginConfiguration()
            captureSession.inputs.forEach { captureSession.removeInput($0) }
            captureSession.addInput(newInput)
            captureSession.commitConfiguration()
            isUsingFrontCamera = !isUsingFrontCamera
        }
        
    }
    
    
    @IBAction func micButtonAction(_ sender: Any) {
        
    }
    

    @IBAction func videoButtonAction(_ sender: Any) {
        // Toggle the video track's enabled state
        do {
            try self.meetingSession?.audioVideo.startLocalVideo()
        } catch PermissionError.videoPermissionError {
            // Handle the case where no permission is granted.
        } catch {
            // Catch some other errors.
        }
        
    }
    
    
    @IBAction func speakerButtonAction(_ sender: Any) {

    }
 
    
    @IBAction func callButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func sideMenuAction(_ sender: Any) {
        showSideMenu(duration: 0.3)
    }
    
    
    @IBAction func dotsAction(_ sender: Any) {
        
    }
    

    
    
    
    //MARK: Functions
    
    
    func getJoinData(){
        
        
//        let url = U_BASE + U_MEETING + "/" + ""
//        
//        "https://vfair-api.upace.in/api/v1/v-fair/meeting/602b67d38482c26e443c286b?event_id=vfe-4146c92c-8695-4623-9cc7-d78bec44bb38&counsellor_id=65e808e557c83feec9d2f95a"
//        
        let url = "https://vfair-beta-api.upace.in/api/v1/v-fair/meeting/602b67d38482c26e443c286b?event_id=vfe-86e00b66-400f-41b7-962a-e0a8acaba612&counsellor_id=65e808e557c83feec9d2f95a"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: JoinInfoResponse.self, requestCode: U_EVENT) { response in
            guard let response = response else{
                LOG("Error in getting response")
                return
            }
           
            self.joinData = response
            
            print("🟢joinData \(String(describing: self.joinData))")
            self.mediaPlacementData = parse(data: self.joinData?.data?.JoinInfo?.Meeting?.MediaPlacement ?? "")
            
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
        
        
        print("🟢🟢🟢Meeting : \(meeting)")
        
        
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
            print("Succes in start ocal video")
        } catch PermissionError.videoPermissionError {
            print("PermissionError.videoPermissionError")
            // Handle the case where no permission is granted.
        } catch {
            print("other error in local video")
            // Catch some other errors.
        }
        
        
        
        // Start remote video.
        meetingSession?.audioVideo.startRemoteVideo()
        
        
        //4. resister observer
        // Register observer.
//        self.meetingSession?.audioVideo.addAudioVideoObserver(observer: self)
//        self.meetingSession?.audioVideo.addRealtimeObserver(observer: self)
        self.meetingSession?.audioVideo.addVideoTileObserver(observer: self)
        
        //5. connecting video (binfing video)
    }
    

    
}











//MARK: Meeting Observer

extension VideoCallViewController: AudioVideoObserver {
    func audioSessionDidStartConnecting(reconnecting: Bool) {
        LOG("audioSessionDidStartConnecting")
    }
    
    func audioSessionDidStart(reconnecting: Bool) {
        LOG("audioSessionDidStart \(reconnecting)")
    }
    
    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("audioSessionDidStopWithStatus \(sessionStatus)")
    }
    
    func audioSessionDidCancelReconnect() {
        LOG("audioSessionDidCancelReconnect")
    }
    
    func connectionDidRecover() {
        LOG("connectionDidRecover")
    }
    
    func connectionDidBecomePoor() {
        LOG("connectionDidBecomePoor")
    }
    
    func videoSessionDidStartConnecting() {
        LOG("videoSessionDidStartConnecting")
    }
    
    func videoSessionDidStartWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("videoSessionDidStartWithStatus \(sessionStatus)")
    }
    
    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        LOG("videoSessionDidStopWithStatus \(sessionStatus)")
    }
    
    func audioSessionDidDrop() {
        LOG("audioSessionDidDrop")
    }
    
    func remoteVideoSourcesDidBecomeAvailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        LOG("audioSessionDidStartConnecting")
    }
    
    func remoteVideoSourcesDidBecomeUnavailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        LOG("remoteVideoSourcesDidBecomeAvailable \(sources)")
    }
    
    func cameraSendAvailabilityDidChange(available: Bool) {
        LOG("cameraSendAvailabilityDidChange \(available)")
    }
    
}



extension VideoCallViewController: RealtimeObserver {
    func volumeDidChange(volumeUpdates: [AmazonChimeSDK.VolumeUpdate]) {
        LOG("volumeDidChange \(volumeUpdates)")
    }
    
    func signalStrengthDidChange(signalUpdates: [AmazonChimeSDK.SignalUpdate]) {
        LOG("signalStrengthDidChange \(signalUpdates)")
    }
    
    func attendeesDidJoin(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("attendeesDidJoin \(attendeeInfo)")
    }
    
    func attendeesDidLeave(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("attendeesDidLeave \(attendeeInfo)")
    }
    
    func attendeesDidMute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("attendeesDidMute \(attendeeInfo)")
    }
    
    func attendeesDidUnmute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("attendeesDidUnmute \(attendeeInfo)")
    }
    
    func attendeesDidDrop(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        LOG("attendeesDidDrop \(attendeeInfo)")
    }
    
    
}



extension VideoCallViewController: VideoTileObserver {
    func videoTileSizeDidChange(tileState: AmazonChimeSDK.VideoTileState) {
        LOG("videoTileSizeDidChange \(tileState)")
        
        // Bind video tile.
        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
    
    func videoTileDidAdd(tileState: VideoTileState) {
        LOG("🟢videoTileDidAdd \(tileState)")
        
        // Bind video tile.
        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
    func videoTileDidRemove(tileState: VideoTileState) {
        LOG("videoTileDidRemove \(tileState)")
        
        
    }
    func videoTileDidPause(tileState: VideoTileState) {
        LOG("videoTileDidPause \(tileState)")
        // Bind video tile.
        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
    func videoTileDidResume(tileState: VideoTileState) {
        LOG("videoTileDidResume \(tileState)")
        // Bind video tile.
        self.meetingSession?.audioVideo.bindVideoView(videoView: defaultVideoRenderView, tileId: tileState.tileId )
    }
}



































//MARK: Side Queue View
extension VideoCallViewController  : UITableViewDataSource, UITableViewDelegate {

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

        // Tap Gesture Recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
//        tapGesture.delegate = self
//        self.darkScreenView.addGestureRecognizer(tapGesture)
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
