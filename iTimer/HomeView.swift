//  HomeView.swift
import SwiftUI
import AVFoundation
struct HomeView: View {
    @State private var timeRemaining: TimeInterval = 10 // 25 = 1500 секунд
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    @State private var isSound: Bool = true
    @State private var audioPlayer: AVAudioPlayer?
    @State private var hourglassRotation: Double = 0
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        Circle()
                            .trim(from: 0, to: CGFloat(1 - (timeRemaining / 10)))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.degrees(-90))
                    Text(formattedTime())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    ZStack {
                        Image(systemName: "hourglass.bottomhalf.filled")
                            .opacity(hourglassRotation > 90 && hourglassRotation <= 270 ? 0 : 1)
                        
                        Image(systemName: "hourglass.tophalf.filled")
                            .opacity(hourglassRotation > 90 && hourglassRotation <= 270 ? 1 : 0)
                    }
                    .font(.title)
                    .rotation3DEffect(.degrees(hourglassRotation), axis: (x: 0, y: 0, z: 180))
                    .offset(y: 90)
                }
                .frame(maxWidth: 500)
                HStack {
                    Button {
                        isRunning.toggle()
                        if isRunning {
                            startTimer()
                            startHourglassAnimation()
                        } else {
                            stopTimer()
                        }
                    } label: {
                        Image(systemName: isRunning ? "stop.fill" : "play.fill")
                            .foregroundStyle(.foreground)
                            .frame(width: 50, height: 50)
                            .font(.largeTitle)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 30)
            .navigationTitle("iTimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isRunning {
                        Button {
                            isSound.toggle()
                            playAudio(shouldPlay: isSound)
                        } label: {
                            Image(systemName: isSound ? "speaker.wave.1.fill" : "speaker.slash.fill")
                                .foregroundStyle(.foreground)
                                .frame(width: 20, height: 20)
                        }
                    } else {
                        Image(systemName: "speaker.slash.fill")
                            .foregroundStyle(.foreground)
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
    }
    func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let second = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, second)
    }
    private func startHourglassAnimation() {
        if isRunning {
            withAnimation(.linear(duration: 1)) {
                hourglassRotation += 180
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                startHourglassAnimation()
            }
        }
    }
    private func startTimer() {
        playAudio(shouldPlay: isSound)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                playDone(shouldPlay: true)
            }
        }
    }
    private func stopTimer() {
        hourglassRotation = 0
        timer?.invalidate()
        timeRemaining = 10
        isRunning = false
        audioPlayer?.stop()
    }
    private func playAudio(shouldPlay: Bool) {
        if shouldPlay {
            if let url = Bundle.main.url(forResource: "clock_sound", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    print("Не удалось воспроизвести аудио")
                }
            } else {
                print("Не удалось найти аудиофайл")
            }
        } else {
            audioPlayer?.stop()
        }
    }
    private func playDone(shouldPlay: Bool) {
        if shouldPlay {
            if let url = Bundle.main.url(forResource: "done_sound", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    print("Не удалось воспроизвести аудио")
                }
            } else {
                print("Не удалось найти аудиофайл")
            }
        } else {
            audioPlayer?.stop()
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
