import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdviceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Advice For Parents"),
      ),
      body: CollapsingList(),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CollapsingList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CollapsingListState();
  }
}

class CollapsingListState extends State<CollapsingList> {
  SliverPersistentHeader makeHeader(
      String headerText, Color headerColor, String imagePath) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 40.0,
        maxHeight: 200.0,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
             DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(0.0, 1.0),
                  stops: [0.0,1.0],
                  colors: [Color(0x00000000), Color(0x70000000)],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                constraints: BoxConstraints(minHeight: 40,maxHeight: 200),
                  padding: EdgeInsets.only(bottom: 5.0,left: 10.0),
                  child: Text(
                    headerText,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[50],
                        fontSize: 20),
                  ))
            ]),
          ],
        ),
      ),
    );
  }

  String consistentText =
      "Children with ASD have a hard time applying what they’ve learned in one setting (such as the therapist’s office or school) to others, including the home. For example, your child may use sign language at school to communicate, but never think to do so at home. Creating consistency in your child’s environment is the best way to reinforce learning. Find out what your child’s therapists are doing and continue their techniques at home. Explore the possibility of having therapy take place in more than one place in order to encourage your child to transfer what he or she has learned from one environment to another. It’s also important to be consistent in the way you interact with your child and deal with challenging behaviors.";
  String scheduleText =
      " Children with ASD tend to do best when they have a highly-structured schedule or routine. Again, this goes back to the consistency they both need and crave. Set up a schedule for your child, with regular times for meals, therapy, school, and bedtime. Try to keep disruptions to this routine to a minimum. If there is an unavoidable schedule change, prepare your child for it in advance.";
  String rewardText =
      " Positive reinforcement can go a long way with children with ASD, so make an effort to “catch them doing something good.” Praise them when they act appropriately or learn a new skill, being very specific about what behavior they’re being praised for. Also look for other ways to reward them for good behavior, such as giving them a sticker or letting them play with a favorite toy.";
  String safetyText =
      " Carve out a private space in your home where your child can relax, feel secure, and be safe. This will involve organizing and setting boundaries in ways your child can understand. Visual cues can be helpful (colored tape marking areas that are off limits, labeling items in the house with pictures). You may also need to safety proof the house, particularly if your child is prone to tantrums or other self-injurious behaviors.";
  String nonverbalText =
      "If you are observant and aware, you can learn to pick up on the nonverbal cues that children with ASD use to communicate. Pay attention to the kinds of sounds they make, their facial expressions, and the gestures they use when they’re tired, hungry, or want something.";
  String tantrumsText =
      "It’s only natural to feel upset when you are misunderstood or ignored, and it’s no different for children with ASD. When children with ASD act out, it’s often because you’re not picking up on their nonverbal cues. Throwing a tantrum is their way of communicating their frustration and getting your attention.";
  String funText =
      "A child coping with ASD is still a child. For both children with ASD and their parents, there needs to be more to life than therapy. Schedule playtime when your child is most alert and awake. Figure out ways to have fun together by thinking about the things that make your child smile, laugh, and come out of her/his shell. Your child is likely to enjoy these activities most if they don’t seem therapeutic or educational. There are tremendous benefits that result from your enjoyment of your child’s company and from your child’s enjoyment of spending unpressured time with you. Play is an essential part of learning for all children and shouldn’t feel like work.";
  String sensoryText =
      "Many children with ASD are hypersensitive to light, sound, touch, taste, and smell. Some children with autism are “under-sensitive” to sensory stimuli. Figure out what sights, sounds, smells, movements, and tactile sensations trigger your kid’s “bad” or disruptive behaviors and what elicits a positive response. What does your child find stressful? Calming? Uncomfortable? Enjoyable? If you understand what affects your child, you’ll be better at troubleshooting problems, preventing situations that cause difficulties, and creating successful experiences.";

  @override
  Widget build(BuildContext context) {
    return  CustomScrollView(
      slivers: <Widget>[
        makeHeader(
            "Be Consistent", Colors.amber, 'assets/images/misc/autism1.png'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Stick to a schedule", Colors.blue, 'assets/images/misc/autism2.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Reward good behavior", Colors.amber, 'assets/images/misc/autism3.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Create a home safety zone", Colors.amber, 'assets/images/misc/autism4.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Look for nonverbal cues", Colors.amber, 'assets/images/misc/autism5.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Figure out the motivation behind the tantrum", Colors.amber, 'assets/images/misc/autism6.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Make time for fun", Colors.amber, 'assets/images/misc/autism7.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        makeHeader(
            "Pay attention to your child’s sensory sensitivities", Colors.amber, 'assets/images/misc/autism8.jpg'),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              padding: EdgeInsets.all(15.0),
              child: Text(consistentText),
            )
          ]),
        ),
        SliverFillRemaining()
      ],
    );
  }
}
