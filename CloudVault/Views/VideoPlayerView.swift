import SwiftUI
import AVFoundation

struct VideoPlayerView: View {
    
    @State var videoURL: URL
    @State var showsControls = true
    @State var videoGravity = AVLayerVideoGravity.resizeAspect
    @State var loop = false
    @State var isMuted = true
    @State var isPlaying = true
    
    var body: some View {
        
        Video(url: videoURL)
            .isPlaying($isPlaying)
            .isMuted($isMuted)
            .playbackControls(showsControls)
            .loop($loop)
            .videoGravity(videoGravity)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.6, alignment: .center)
        
    }
}
