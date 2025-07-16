import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ripple_wave/ripple_wave.dart';
import 'intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 @override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 5), () {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroScreen()),
      );
    });
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 246, 254, 1),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Top background circles
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(211, 230, 255, 1),
                        Color.fromRGBO(221, 233, 253, 1),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(212, 239, 244, 1),
                        Color.fromRGBO(227, 245, 251, 1),
                      ],
                    ),
                  ),
                ),
              ),

              
              Align(
  alignment: Alignment(0, -0.3), 
  child: Column(

                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                     SizedBox(
  width: 150, 
  height: 150,
  child: Stack(
    alignment: Alignment.center,
    children: [
      
      RippleWave(
  waveCount: 5, 
  color: const Color.fromRGBO(163, 87, 247, 0.3), 
  repeat: true,
  duration: const Duration(milliseconds: 1800), 
  child: Container(
    width: 80, 
    height: 80,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          Color.fromRGBO(116, 107, 243, 1),
          Color.fromRGBO(163, 87, 247, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(
        Icons.location_on_outlined,
        size: 32, 
        color: Colors.white,
      ),
    ),
  )
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .scaleXY(
        begin: 1.0,
        end: 1.05, 
        duration: 1000.ms,
        curve: Curves.easeInOut,
      ),
),


      
      // Top-Left Icon
Transform.translate(
  offset: const Offset(-120, -120),
  child: const Icon(
    CupertinoIcons.circle_grid_hex,
    size: 28,
    color: Color.fromRGBO(116, 107, 243, 1),
  )
      .animate(onPlay: (c) => c.repeat())
      .moveY(begin: 0, end: -4, duration: 600.ms)
      .then()
      .moveY(begin: -4, end: 0, duration: 600.ms),
),

// Left Icon
Transform.translate(
  offset: const Offset(-140, 0),
  child: const Icon(
    Icons.satellite_alt_rounded,
    size: 28,
    color: Color.fromRGBO(113, 108, 208, 1),
  )
      .animate(onPlay: (c) => c.repeat())
      .moveY(begin: 0, end: -4, duration: 600.ms)
      .then()
      .moveY(begin: -4, end: 0, duration: 600.ms),
),

// Right Icon
Transform.translate(
  offset: const Offset(140, 0),
  child: const Icon(
    CupertinoIcons.location_fill,
    size: 28,
    color: Color.fromRGBO(163, 87, 247, 1),
  )
      .animate(onPlay: (c) => c.repeat())
      .moveY(begin: 0, end: -6, duration: 600.ms)
      .then()
      .moveY(begin: -6, end: 0, duration: 600.ms),
),

    ],
  ),
),





                      const SizedBox(height: 20),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color.fromRGBO(116, 107, 243, 1),
                            Color.fromRGBO(163, 87, 247, 1),
                          ],
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: const Text(
                          "GPS Tracker",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Experience the future of location tracking\nwith precision, security, and style.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
