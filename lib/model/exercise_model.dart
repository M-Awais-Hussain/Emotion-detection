class Exercise {
  final String title;
  final String image;
  final String description;
  final String technique;
  final String advantages;
  final String history;

  const Exercise({
    required this.title,
    required this.image,
    required this.description,
    required this.technique,
    required this.advantages,
    required this.history,
  });
}

final Map<String, List<Exercise>> exercise = {
  // ------------------- HAPPY -------------------
  "happy": [
    Exercise(
      title: "Bridge Pose",
      image: "assets/exercises/happy/setu_bandhasana.png",
      description:
      "Setu Bandhasana, commonly known as Bridge Pose, is a reclining backbend yoga posture that opens the chest and strengthens the spine.",
      technique:
      "1. Lie flat on your back with knees bent and feet hip-width apart.\n"
          "2. Place your arms beside your body, palms facing down.\n"
          "3. Press feet into the floor and lift hips towards the ceiling.\n"
          "4. Clasp hands under your back and press shoulders into the mat.\n"
          "5. Hold for 30–60 seconds while breathing deeply.",
      advantages:
      "• Strengthens the back, glutes, and hamstrings.\n"
          "• Opens the chest and lungs, improving respiration.\n"
          "• Reduces anxiety, stress, and fatigue.\n"
          "• Stimulates thyroid and abdominal organs.",
      history:
      "The name derives from Sanskrit: 'Setu' (bridge), 'Bandha' (lock), and 'Asana' (pose). It has been practiced in traditional Hatha Yoga to promote balance and rejuvenation.",
    ),
    Exercise(
      title: "Sun Salutation",
      image: "assets/exercises/happy/suryanamaskar.png",
      description:
      "Surya Namaskar is a dynamic sequence of 12 yoga postures performed in a flow, honoring the Sun and boosting vitality.",
      technique:
      "1. Begin in Prayer Pose (Pranamasana).\n"
          "2. Move into Raised Arms Pose (Hasta Uttanasana).\n"
          "3. Fold forward into Standing Forward Bend (Uttanasana).\n"
          "4. Step back into Ashwa Sanchalanasana (Equestrian Pose).\n"
          "5. Transition into Plank Pose.\n"
          "6. Lower down in Ashtanga Namaskar.\n"
          "7. Lift into Cobra Pose (Bhujangasana).\n"
          "8. Move into Downward Dog (Adho Mukha Svanasana).\n"
          "9. Step forward into Equestrian Pose.\n"
          "10. Return to Forward Bend.\n"
          "11. Rise into Raised Arms Pose.\n"
          "12. Return to Prayer Pose.",
      advantages:
      "• Improves blood circulation and flexibility.\n"
          "• Enhances cardiovascular health.\n"
          "• Boosts mood and reduces stress.\n"
          "• Stimulates metabolism and aids digestion.",
      history:
      "Surya Namaskar dates back thousands of years as a ritual to worship the Sun God. It is integral to many yoga traditions as a holistic practice.",
    ),
    Exercise(
      title: "Warrior Pose",
      image: "assets/exercises/happy/virabhadrasana.png",
      description:
      "Virabhadrasana, or Warrior Pose, is a powerful standing posture that builds stamina and focus.",
      technique:
      "1. Stand with feet wide apart.\n"
          "2. Turn right foot out 90 degrees and left foot slightly in.\n"
          "3. Bend the right knee and extend arms parallel to the floor.\n"
          "4. Gaze forward over right hand.\n"
          "5. Hold for 20–40 seconds, then repeat on other side.",
      advantages:
      "• Strengthens legs, arms, and core.\n"
          "• Improves balance and stability.\n"
          "• Energizes the body and mind.\n"
          "• Boosts self-confidence.",
      history:
      "Named after Virabhadra, a fierce warrior from Hindu mythology, this pose embodies courage and focus.",
    ),
   
  ],

  // ------------------- ANGRY -------------------
  "angry": [
    Exercise(
      title: "Child's Pose",
      image: "assets/exercises/angry/balasana.png",
      description:
      "Balasana is a gentle resting pose that relaxes the body and mind, often used to relieve tension and stress.",
      technique:
      "1. Kneel on the mat and touch your big toes together.\n"
          "2. Sit back on your heels and fold forward, extending arms in front or beside your body.\n"
          "3. Rest forehead on the mat.\n"
          "4. Hold for 1–3 minutes, breathing slowly and deeply.",
      advantages:
      "• Reduces stress and fatigue.\n"
          "• Stretches hips, thighs, and ankles.\n"
          "• Calms the mind and relieves tension.",
      history:
      "Balasana is a traditional Hatha Yoga pose commonly used in sequences to rest between more demanding asanas.",
    ),
    Exercise(
      title: "Cat-Cow Pose",
      image: "assets/exercises/angry/marjaryasana_bitilasana.png",
      description:
      "A gentle flow between Cat and Cow poses to increase flexibility and release tension along the spine.",
      technique:
      "1. Begin on all fours with hands under shoulders and knees under hips.\n"
          "2. Inhale, drop belly, lift tailbone and head (Cow Pose).\n"
          "3. Exhale, round spine, tuck chin (Cat Pose).\n"
          "4. Repeat 10–15 cycles slowly.",
      advantages:
      "• Improves spinal flexibility.\n"
          "• Relieves tension in neck, back, and shoulders.\n"
          "• Massages organs and improves circulation.",
      history:
      "This flow is rooted in Hatha Yoga to cultivate awareness of breath and body alignment.",
    ),
    Exercise(
      title: "Alternate Nostril Breathing",
      image: "assets/exercises/angry/nadi_shodhana.png",
      description:
      "A calming pranayama technique to balance energy and reduce anger or stress.",
      technique:
      "1. Sit comfortably with a straight spine.\n"
          "2. Use right thumb to close right nostril.\n"
          "3. Inhale through left nostril.\n"
          "4. Close left nostril with ring finger and exhale through right nostril.\n"
          "5. Inhale through right, exhale left; continue for 5–10 minutes.",
      advantages:
      "• Reduces stress and anxiety.\n"
          "• Balances nervous system and energy channels.\n"
          "• Promotes mental clarity and emotional stability.",
      history:
      "Nadi Shodhana is an ancient pranayama from classical yoga texts to purify 'nadis' (energy channels).",
    ),
  
  ],

  // ------------------- SAD -------------------
  "sad": [
    Exercise(
      title: "Fish Pose ",
      image: "assets/exercises/sad/matsyasana.png",
      description:
      "Matsyasana opens the chest and throat, helping to lift mood and energy levels.",
      technique:
      "1. Lie on your back, legs extended.\n"
          "2. Place hands under hips, palms down.\n"
          "3. Inhale, lift chest and head backward.\n"
          "4. Crown of head rests gently on the floor.\n"
          "5. Hold 20–40 seconds, breathe deeply.",
      advantages:
      "• Opens chest and lungs, aiding respiration.\n"
          "• Relieves mild depression and fatigue.\n"
          "• Stretches throat and spine.",
      history:
      "Matsyasana, 'Fish Pose,' is a traditional yoga posture that stimulates energy flow and relieves lethargy.",
    ),
    Exercise(
      title: "Seated Forward Bend",
      image: "assets/exercises/sad/paschimottanasana.png",
      description:
      "A calming forward bend that stretches the spine and hamstrings while soothing the mind.",
      technique:
      "1. Sit with legs extended.\n"
          "2. Inhale, lengthen spine.\n"
          "3. Exhale, bend forward and reach for feet or shins.\n"
          "4. Hold 30–60 seconds, breathe evenly.",
      advantages:
      "• Stretches spine, shoulders, and hamstrings.\n"
          "• Reduces stress and mild depression.\n"
          "• Stimulates liver and kidneys.",
      history:
      "A foundational Hatha Yoga posture known for calming the nervous system.",
    ),
    Exercise(
      title: "Reclining Bound Angle Pose",
      image: "assets/exercises/sad/supta_baddha_konasana.png",
      description:
      "A restorative pose that opens hips and promotes relaxation.",
      technique:
      "1. Lie on back.\n"
          "2. Bring soles of feet together, knees out to sides.\n"
          "3. Rest arms by your sides.\n"
          "4. Hold 2–5 minutes, breathing deeply.",
      advantages:
      "• Opens hips and groin.\n"
          "• Relieves anxiety and mild depression.\n"
          "• Promotes deep relaxation.",
      history:
      "Supta Baddha Konasana has long been used in yoga for restorative and meditative purposes.",
    ),
  ],

  // ------------------- NEUTRAL -------------------
  "neutral": [
    Exercise(
      title: "Half Moon Pose",
      image: "assets/exercises/neutral/ardha_chandrasana.png",
      description:
      "A balancing posture that strengthens the legs and core, while improving focus.",
      technique:
      "1. Stand in Triangle Pose, then shift weight onto front foot.\n"
          "2. Lift back leg parallel to floor.\n"
          "3. Extend top arm toward ceiling, gaze upward.\n"
          "4. Hold 20–30 seconds per side.",
      advantages:
      "• Improves balance and coordination.\n"
          "• Strengthens legs, core, and spine.\n"
          "• Enhances focus and concentration.",
      history:
      "Ardha Chandrasana, 'Half Moon,' is a classical yoga pose that develops stability and poise.",
    ),
    Exercise(
      title: "Cat-Cow Pose",
      image: "assets/exercises/neutral/marjaryasana_bitilasana.png",
      description:
      "Gentle flow to increase spinal flexibility and body awareness.",
      technique:
      "1. Begin on all fours.\n"
          "2. Inhale into Cow Pose (belly down).\n"
          "3. Exhale into Cat Pose (spine rounded).\n"
          "4. Repeat 10–15 cycles.",
      advantages:
      "• Improves spine mobility.\n"
          "• Reduces tension in neck and back.\n"
          "• Promotes mindfulness and breathing awareness.",
      history:
      "Ancient Hatha Yoga practice to harmonize breath with movement.",
    ),
    Exercise(
      title: "Meditation",
      image: "assets/exercises/neutral/meditation.png",
      description:
      "Practice of quieting the mind to improve awareness and emotional balance.",
      technique:
      "1. Sit comfortably with spine straight.\n"
          "2. Close eyes, focus on breath.\n"
          "3. Let thoughts pass without attachment.\n"
          "4. Practice for 10–20 minutes daily.",
      advantages:
      "• Improves focus and mental clarity.\n"
          "• Reduces stress and anxiety.\n"
          "• Enhances emotional stability.",
      history:
      "Meditation has been a core practice in yoga and spiritual traditions for thousands of years.",
    ),
  ],

  // ------------------- FEAR -------------------
  "fear": [
    Exercise(
      title: "Grounding Breathing",
      image: "assets/exercises/anxious/breathing.png",
      description:
      "A calming breathing technique to activate the parasympathetic nervous system and reduce feelings of panic.",
      technique:
      "1. Find a comfortable, safe space to sit or lie down.\n"
          "2. Inhale deeply through your nose for a count of 4.\n"
          "3. Hold your breath for a count of 4.\n"
          "4. Exhale slowly through your mouth for a count of 6.\n"
          "5. Repeat this cycle 5–10 times until you feel grounded.",
      advantages:
      "• Lowers heart rate and blood pressure.\n"
          "• Reduces acute feelings of fear or panic.\n"
          "• Restores a sense of control and calm.",
      history:
      "Controlled breathing exercises have been used for centuries across various traditions to manage stress and fear.",
    ),
    Exercise(
      title: "Mindful Observation",
      image: "assets/exercises/neutral/meditation.png",
      description:
      "A technique to shift focus away from fearful thoughts by engaging with the present environment.",
      technique:
      "1. Sit quietly and look around your environment.\n"
          "2. Name 5 things you can see.\n"
          "3. Name 4 things you can physically feel.\n"
          "4. Name 3 things you can hear.\n"
          "5. Name 2 things you can smell, and 1 thing you can taste.",
      advantages:
      "• Interrupts fearful rumination.\n"
          "• Brings the mind back to the present moment.\n"
          "• Creates a mental pause to process emotions.",
      history:
      "The 5-4-3-2-1 technique is a well-established cognitive behavioral tool for grounding during acute anxiety or fear.",
    ),
  ],

  // ------------------- DISGUST -------------------
  "disgust": [
    Exercise(
      title: "Cleansing Breath",
      image: "assets/exercises/anxious/breathing.png",
      description:
      "A refreshing breathing practice to help release feelings of aversion and restore emotional neutrality.",
      technique:
      "1. Sit comfortably with a straight spine.\n"
          "2. Take a deep, slow breath in through your nose, imagining drawing in clean, fresh energy.\n"
          "3. Exhale forcefully through your mouth, visualizing the expulsion of negative feelings.\n"
          "4. Repeat 5–8 times, focusing on the cleansing sensation.",
      advantages:
      "• Helps clear lingering negative emotions.\n"
          "• Resets the nervous system.\n"
          "• Promotes a feeling of internal purity and calm.",
      history:
      "Various 'cleansing breath' techniques are used in yoga and mindfulness to release stagnant energy and emotions.",
    ),
    Exercise(
      title: "Body Scan Meditation",
      image: "assets/exercises/neutral/meditation.png",
      description:
      "A mindfulness practice to reconnect with the body in a neutral, non-judgmental way.",
      technique:
      "1. Lie down on your back in a comfortable position.\n"
          "2. Close your eyes and bring attention to your toes.\n"
          "3. Slowly move your focus up through your legs, torso, arms, and head.\n"
          "4. Notice any sensations without judgment, simply acknowledging them.\n"
          "5. Practice for 10–15 minutes.",
      advantages:
      "• Cultivates self-compassion and acceptance.\n"
          "• Reduces physical tension associated with aversion.\n"
          "• Grounds the mind in physical reality.",
      history:
      "Body scanning is a core practice in Mindfulness-Based Stress Reduction (MBSR) programs.",
    ),
  ],

  // ------------------- SURPRISE -------------------
  "surprise": [
    Exercise(
      title: "Centering Pose",
      image: "assets/exercises/neutral/ardha_chandrasana.png",
      description:
      "A gentle balancing pose to help the mind and body find equilibrium after an unexpected event.",
      technique:
      "1. Stand tall with feet hip-width apart.\n"
          "2. Place your hands on your heart or belly.\n"
          "3. Feel your feet firmly planted on the ground.\n"
          "4. Take slow, steady breaths, focusing on the stability of your stance.\n"
          "5. Hold for 1–2 minutes to allow your nervous system to settle.",
      advantages:
      "• Restores physical and emotional balance.\n"
          "• Calms the startled response.\n"
          "• Encourages a feeling of safety and presence.",
      history:
      "Standing and centering practices are foundational in both yoga (Mountain Pose) and martial arts to regain composure.",
    ),
    Exercise(
      title: "Progressive Muscle Relaxation",
      image: "assets/exercises/sad/supta_baddha_konasana.png",
      description:
      "A systematic technique to release sudden tension that may have built up from feeling startled or surprised.",
      technique:
      "1. Sit or lie down comfortably.\n"
          "2. Tense the muscles in your feet for 5 seconds, then release completely.\n"
          "3. Move up to your calves, tense for 5 seconds, and release.\n"
          "4. Continue up through your thighs, abdomen, arms, and face.\n"
          "5. Enjoy the feeling of complete relaxation for a few minutes.",
      advantages:
      "• Identifies and releases involuntary muscle tension.\n"
          "• Signals the brain that the 'threat' or surprise has passed.\n"
          "• Promotes deep physical relaxation.",
      history:
      "Developed by Edmund Jacobson in the 1920s, this technique is widely used to manage acute stress responses.",
    ),
  ],
};
