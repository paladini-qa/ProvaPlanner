import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppTheme.indigo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Calendário base
          Positioned(
            top: size * 0.15,
            left: size * 0.1,
            right: size * 0.1,
            child: Container(
              height: size * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Cabeçalho do calendário
                  Container(
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: AppTheme.amber,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: size * 0.3,
                        height: size * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Dias do calendário
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.05),
                      child: Column(
                        children: [
                          // Linha de dias
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (index) {
                              return Container(
                                width: size * 0.06,
                                height: size * 0.06,
                                decoration: BoxDecoration(
                                  color: index < 3 ? AppTheme.indigo : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: size * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (index) {
                              return Container(
                                width: size * 0.06,
                                height: size * 0.06,
                                decoration: BoxDecoration(
                                  color: index < 2 ? AppTheme.indigo : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lápis
          Positioned(
            top: size * 0.05,
            right: size * 0.05,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: size * 0.25,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: AppTheme.amber,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    // Corpo do lápis
                    Positioned(
                      top: size * 0.05,
                      left: size * 0.08,
                      child: Container(
                        width: size * 0.08,
                        height: size * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Ponta do lápis
                    Positioned(
                      bottom: 0,
                      left: size * 0.06,
                      child: Container(
                        width: 0,
                        height: 0,
                        borderLeft: BorderSide(
                          color: Colors.transparent,
                          width: size * 0.05,
                        ),
                        borderRight: BorderSide(
                          color: Colors.transparent,
                          width: size * 0.05,
                        ),
                        borderBottom: BorderSide(
                          color: AppTheme.slate,
                          width: size * 0.08,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
