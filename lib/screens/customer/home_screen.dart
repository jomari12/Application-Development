import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Experience Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(screenWidth),
              vertical: isMobile ? 30 : 60,
            ),
            child: Column(
              children: [
                Text(
                  'Experience the Best of Beach Life',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : (isTablet ? 30 : 36),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Inter',
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 30 : 60),
                
                // Responsive image layout
                _buildImageLayout(isMobile, isTablet),
                
                SizedBox(height: isMobile ? 20 : 40),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to accommodations
                    DefaultTabController.of(context).animateTo(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 32,
                      vertical: isMobile ? 12 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'View More',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 40 : 80),

          // Testimonials Section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(screenWidth),
              vertical: isMobile ? 30 : 60,
            ),
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                Text(
                  'What Our Guests Say',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : (isTablet ? 30 : 36),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Inter',
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 30 : 60),
                
                // Responsive testimonials layout
                _buildTestimonialsLayout(isMobile, isTablet),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 40 : 80),
        ],
      ),
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth <= 768) {
      return 16; // Mobile
    } else if (screenWidth <= 1024) {
      return 40; // Tablet
    } else {
      return 80; // Desktop
    }
  }

  Widget _buildImageLayout(bool isMobile, bool isTablet) {
    if (isMobile) {
      // Stack images vertically on mobile
      return Column(
        children: [
          _buildImageContainer('../../assets/images/image1.jpg?w=400', 200),
          const SizedBox(height: 16),
          _buildImageContainer('../../assets/images/image2.png?w=400', 200),
          const SizedBox(height: 16),
          _buildImageContainer('../../assets/images/image3.jpg?w=400', 200),
        ],
      );
    } else if (isTablet) {
      // 2x2 grid on tablet with one image taking full width
      return Column(
        children: [
          _buildImageContainer('../../assets/images/image1.jpg?w=400', 250),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImageContainer('../../assets/images/image2.png?w=400', 200),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageContainer('../../assets/images/image3.jpg?w=400', 200),
              ),
            ],
          ),
        ],
      );
    } else {
      // Original row layout for desktop
      return Row(
        children: [
          Expanded(
            child: _buildImageContainer('../../assets/images/image1.jpg?w=400', 300),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildImageContainer('../../assets/images/image2.png?w=400', 300),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildImageContainer('../../assets/images/image3.jpg?w=400', 300),
          ),
        ],
      );
    }
  }

  Widget _buildImageContainer(String imageUrl, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTestimonialsLayout(bool isMobile, bool isTablet) {
    final testimonials = [
      {
        'review': "The most beautiful beach I've ever seen. The staff was incredibly attentive and the food was amazing. Can't wait to come back!",
        'name': 'Michael T.',
        'rating': 5,
      },
      {
        'review': "The view, the vibe, and the service were all top-notch. Perfect spot for a relaxing getaway.",
        'name': 'Lisa R.',
        'rating': 5,
      },
      {
        'review': "Our family had the best vacation ever! The kids loved the activities and we enjoyed the spa. The booking process was seamless and wonderful.",
        'name': 'Sara H.',
        'rating': 5,
      },
      {
        'review': "The most beautiful beach I've ever seen. The staff was incredibly attentive and the food was amazing. Can't wait to come back!",
        'name': 'Chris D.',
        'rating': 5,
      },
      {
        'review': "Loved every moment. From the hammocks under the palms to the ocean breeze—pure bliss.",
        'name': 'Lara K.',
        'rating': 5,
      },
      {
        'review': "My kids had a blast with the activities, and we enjoyed the spa and the seafood. A great experience for all ages.",
        'name': 'Monica L.',
        'rating': 5,
      },
    ];

    if (isMobile) {
      // Single column on mobile
      return Column(
        children: testimonials.map((testimonial) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTestimonialCard(
              testimonial['review'] as String,
              testimonial['name'] as String,
              testimonial['rating'] as int,
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      // 2 columns on tablet
      return Column(
        children: [
          for (int i = 0; i < testimonials.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTestimonialCard(
                      testimonials[i]['review'] as String,
                      testimonials[i]['name'] as String,
                      testimonials[i]['rating'] as int,
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (i + 1 < testimonials.length)
                    Expanded(
                      child: _buildTestimonialCard(
                        testimonials[i + 1]['review'] as String,
                        testimonials[i + 1]['name'] as String,
                        testimonials[i + 1]['rating'] as int,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      );
    } else {
      // Original 3-column layout for desktop
      return Column(
        children: [
          // First row
          Row(
            children: [
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[0]['review'] as String,
                  testimonials[0]['name'] as String,
                  testimonials[0]['rating'] as int,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[1]['review'] as String,
                  testimonials[1]['name'] as String,
                  testimonials[1]['rating'] as int,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[2]['review'] as String,
                  testimonials[2]['name'] as String,
                  testimonials[2]['rating'] as int,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Second row
          Row(
            children: [
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[3]['review'] as String,
                  testimonials[3]['name'] as String,
                  testimonials[3]['rating'] as int,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[4]['review'] as String,
                  testimonials[4]['name'] as String,
                  testimonials[4]['rating'] as int,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  testimonials[5]['review'] as String,
                  testimonials[5]['name'] as String,
                  testimonials[5]['rating'] as int,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTestimonialCard(String review, String name, int rating) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '"$review"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontFamily: 'Inter',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFBBF24),
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            radius: 20,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}