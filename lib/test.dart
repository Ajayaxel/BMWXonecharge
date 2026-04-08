import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/data/models/combo_offer_model.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_bloc.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_state.dart';
import 'package:onecharge/logic/blocs/combo_offer/presentation/bloc/combo_offer_event.dart';

class Test extends StatelessWidget {
  final ComboOfferModel? offer;
  const Test({super.key, this.offer});

  @override
  Widget build(BuildContext context) {
    // If offer is passed, use it directly (useful for testing or sub-widgets)
    if (offer != null) {
      return _buildContent(context, offer!);
    }

    // Otherwise, consume the Bloc
    return BlocBuilder<ComboOfferBloc, ComboOfferState>(
      builder: (context, state) {
        if (state is ComboOfferInitial) {
          context.read<ComboOfferBloc>().add(FetchComboOffers());
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ComboOfferLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ComboOfferLoaded) {
          if (state.comboOffers.isEmpty) {
            return const Scaffold(body: Center(child: Text("No offers found")));
          }
          final firstOffer = state.comboOffers.first;
          return _buildContent(context, firstOffer);
        } else if (state is ComboOfferError) {
          return Scaffold(body: Center(child: Text("Error: ${state.message}")));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildContent(BuildContext context, ComboOfferModel offer) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
          child: Column(
            children: [
              CustomPaint(
                painter: TicketSeparatorPainter(notchPositionFactor: 0.50),
                child: ClipPath(
                  clipper: TicketClipper(notchPositionFactor: 0.50),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        100,
                        209,
                        233,
                      ), // Added some background for visibility
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(offer.description),
                        Text(
                          "Price: ${offer.comboPrice}",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double notchPositionFactor;
  TicketClipper({this.notchPositionFactor = 0.70});

  @override
  Path getClip(Size size) {
    // Proportions: Top 65%, Bottom 25%, Neck 10%
    double topDepth = size.height * 0.65;
    double bottomDepth = size.height * 0.25;

    // Horizontal Proportions: Based on notchPositionFactor
    double notchWidth = size.width * 0.05;
    double notchPosition = size.width * notchPositionFactor; 
    double radius = 20;

    Path path = Path();

    // START: Top Left
    path.moveTo(radius, 0);

    // Top Edge to Left Card's Top-Right Detail (Ends at 60%)
    path.lineTo(notchPosition - notchWidth / 2 - radius, 0);
    path.arcToPoint(
      Offset(notchPosition - notchWidth / 2, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Top Notch: Side down
    path.lineTo(notchPosition - notchWidth / 2, topDepth - notchWidth / 2);
    // Top Notch: Round semi-circle base
    path.arcToPoint(
      Offset(notchPosition + notchWidth / 2, topDepth - notchWidth / 2),
      radius: Radius.circular(notchWidth / 2),
      clockwise: false,
    );
    // Top Notch: Side back up
    path.lineTo(notchPosition + notchWidth / 2, radius);
    // ROUNDING: Top Notch Right Shoulder
    path.arcToPoint(
      Offset(notchPosition + notchWidth / 2 + radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Top Edge to Top Right
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
    );

    // Right Edge to Bottom Right
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
    );

    // Bottom Edge to Bottom-Right Shoulder
    path.lineTo(notchPosition + notchWidth / 2 + radius, size.height);
    // ROUNDING: Bottom Notch Right Shoulder
    path.arcToPoint(
      Offset(notchPosition + notchWidth / 2, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Bottom Notch: Side down
    path.lineTo(
      notchPosition + notchWidth / 2,
      size.height - bottomDepth + notchWidth / 2,
    );
    // Bottom Notch: Round semi-circle base
    path.arcToPoint(
      Offset(
        notchPosition - notchWidth / 2,
        size.height - bottomDepth + notchWidth / 2,
      ),
      radius: Radius.circular(notchWidth / 2),
      clockwise: false,
    );
    // Bottom Notch: Side back up
    path.lineTo(notchPosition - notchWidth / 2, size.height - radius);
    // ROUNDING: Bottom Notch Left Shoulder
    path.arcToPoint(
      Offset(notchPosition - notchWidth / 2 - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Bottom Edge to Bottom Left
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
    );

    // Left Edge back to start
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TicketSeparatorPainter extends CustomPainter {
  final double notchPositionFactor;
  TicketSeparatorPainter({required this.notchPositionFactor});

  @override
  void paint(Canvas canvas, Size size) {
    // This is optional: can draw a very subtle faint dashed line
    // to enhance the "tear-off" ticket look.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CircularText extends StatelessWidget {
  final String text;
  const CircularText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularTextPainter(text),
      child: const SizedBox(width: 105, height: 105),
    );
  }
}

class _CircularTextPainter extends CustomPainter {
  final String text;
  _CircularTextPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    canvas.translate(radius, radius);

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Repeat string for full circle if needed
    String fullText = text;
    while (fullText.length < 40) {
      fullText += text;
    }

    double angleStep = (2 * 3.14159) / fullText.length;

    for (int i = 0; i < fullText.length; i++) {
      textPainter.text = TextSpan(text: fullText[i], style: textStyle);
      textPainter.layout();

      canvas.save();
      canvas.rotate(i * angleStep);
      canvas.translate(0, -radius + 8);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
