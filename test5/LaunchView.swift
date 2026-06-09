//
//  LaunchView.swift
//  test5
//
//  加载动画页面
//

import SwiftUI

struct LaunchView: View {
    @Binding var isFinished: Bool
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var dotsOpacity: Double = 0
    @State private var currentDot = 0
    
    var body: some View {
        ZStack {
            // 背景色（渐变黑色）
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo 图片区域 - 您替换成自己的图片
                Image("icon.png") // 临时占位，替换为您的 Logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.mint)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .padding(.leading,30)
                
                // App 名称
                Text("Innoforge")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(logoOpacity)
                
                // Slogan
                Text("智创未来")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .opacity(logoOpacity)
                
                Spacer()
                
                // 加载动画点
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.mint)
                            .frame(width: 10, height: 10)
                            .opacity(currentDot == index ? 1 : 0.3)
                            .scaleEffect(currentDot == index ? 1.2 : 1)
                    }
                }
                .opacity(dotsOpacity)
                .padding(.bottom, 60)
                
                // 加载文字
                Text("正在加载...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .opacity(dotsOpacity)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo 放大淡入动画
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // 延迟显示加载点
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                dotsOpacity = 1.0
            }
            startDotsAnimation()
        }
        
        // 2.5秒后完成加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                isFinished = true
            }
        }
    }
    
    private func startDotsAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.2)) {
                currentDot = (currentDot + 1) % 3
            }
            
            // 2秒后停止动画
            if currentDot == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    LaunchView(isFinished: .constant(false))
}

