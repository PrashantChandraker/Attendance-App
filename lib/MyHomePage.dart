
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Black background at the bottom
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'W',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        TextSpan(
                          text: 'elcome',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "              To",
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  const Text(
                    "              Hitech",
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  )
                ],
              ),
            ),
          ),
          // ClipPath for the wave line and white background at the top
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: Colors.black,
              height: MediaQuery.of(context).size.height *
                  1, // Adjust the height to increase black area
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper to create the wave shape
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from bottom-left corner

    Path path_0 = Path();
    path_0.moveTo(size.width * -0.0025000, size.height * 1.0028571);
    path_0.lineTo(size.width * 0.0416667, size.height * 0.8628571);
    path_0.lineTo(size.width * 0.1250000, size.height * 0.7171429);
    path_0.lineTo(size.width * 0.2166667, size.height * 0.6428571);
    path_0.lineTo(size.width * 0.3275000, size.height * 0.5900000);
    path_0.lineTo(size.width * 0.4608333, size.height * 0.5542857);
    path_0.lineTo(size.width * 0.6158333, size.height * 0.5271429);
    path_0.lineTo(size.width * 0.7516667, size.height * 0.4942857);
    path_0.lineTo(size.width * 0.8716667, size.height * 0.4085714);
    path_0.lineTo(size.width * 0.9591667, size.height * 0.3300000);
    path_0.lineTo(size.width * 0.9966667, size.height * 0.2942857);
    path_0.lineTo(size.width * 1.0075000, size.height * 1.0185714);
    path_0.lineTo(size.width * -0.0025000, size.height * 1.0028571);
    path_0.close();

    return path_0;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
