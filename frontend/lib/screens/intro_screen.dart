import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:gps_tracker/screens/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<String> imagePaths = [
    'assets/intro img 1.jpg',
    'assets/intro img 2.jpg',
  ];

  final List<String> titles = [
    "Real-time GPS Based \nFleet Tracking",
    "Monitor Your Vehicle",
  ];

  final List<String> subtitles = [
    "GPS Tracking and Fleet Management Features.\nProtect your Vehicle from unauthorized activity.",
    "Track and locate your connected fleet with fuel and route historical data.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: _currentIndex == 0 ? 550 : 400,
            child: PageView.builder(
              controller: _controller,
              itemCount: imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // Curved image
                    ClipPath(
                      clipper: BottomCurveClipper(),
                      child: Image.asset(
                        imagePaths[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Top slider bar inside image
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imagePaths.length, (dotIndex) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            width: 100,
                            decoration: BoxDecoration(
                              color: _currentIndex == dotIndex
                                  ? const Color.fromRGBO(29, 19, 184, 1)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          
          DotsIndicator(
            dotsCount: imagePaths.length,
            position: _currentIndex.toDouble(),
            decorator: DotsDecorator(
              activeColor: const Color.fromRGBO(29, 19, 184, 1),
              color: Colors.grey,
              size: const Size.square(8),
              activeSize: const Size(18, 8),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title and subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  titles[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitles[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          if (_currentIndex == 0) ...[
            ElevatedButton(
              onPressed: () {
                if (_controller.hasClients) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color.fromRGBO(29, 19, 184, 1),
                foregroundColor: Colors.white,
              ),
              child: const Icon(Icons.arrow_forward, size: 40),
            ),
          ] else ...[
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Continue with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.apple, size: 26),
                label: const Text("Continue with Apple"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Or"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
            ),

            const SizedBox(height: 15),

           Padding(
  padding: const EdgeInsets.symmetric(horizontal: 25),
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen()),
);

    },
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: const Color.fromRGBO(29, 19, 184, 1),
    ),
    child: const Text(
      "Sign in with Email",
      style: TextStyle(color: Colors.white),
    ),
  ),
),


            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Color.fromRGBO(29, 19, 184, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
