import 'package:yoga_mithra/models/course.dart';
import 'package:yoga_mithra/Views/components/style.dart' as style_component;

final _standStyle = style_component.Style(
  imageUrl: 'assets/images/pose2.png',
  name: 'Shoulder',
  time: 5,
  pageName: "shoulder"
);
final _sittingStyle = style_component.Style(
  imageUrl: 'assets/images/pose1.png',
  name: 'BackPain',
  time: 8,
  pageName: "BackPain"
);
final _legCrossStyle = style_component.Style(
  imageUrl: 'assets/images/pose3.png',
  name: 'Knee pain',
  time: 6,
  pageName: "knee"
);

final styles = [_standStyle, _sittingStyle, _legCrossStyle];

final _course1 = Course(
    imageUrl: 'assets/images/course1.jpg',
    name: 'Advance Stretchings',
    time: 45,
    students: 'Advanced');

final _course2 = Course(
    imageUrl: 'assets/images/course2.jpg',
    name: 'Daily Yoga',
    time: 30,
    students: 'Intermediate');

final _course3 = Course(
    imageUrl: 'assets/images/course3.jpg',
    name: 'Meditation',
    time: 20,
    students: 'Beginner');
    

final List<Course> courses = [_course1, _course3, _course2];


// ############################################################################################################################################################

final _shoulderType1 =
    Shoulder(imageUrl: "assets/images/marjaryasana.png", name: "Cat-Cow pose(marjaryasana)", desc: "The Cat-Cow Pose (Marjaryasana-Bitilasana) is effective for relieving shoulder pain. By gently stretching and mobilizing the spine, it helps alleviate tension in the neck and shoulders,then this pose enhances spinal flexibility and promotes better posture, which can further reduce shoulder discomfort");

final _shoulderType2 =
    Shoulder(imageUrl: "assets/images/adhoMukhaShavasana.png", name: "Adho Mukha Svanasana", desc: "Adho Mukha Svanasana, also known as Downward-Facing Dog, is a foundational yoga asana that requires flexibility and upper body strength. In this asana, the body forms an inverted “V” with the feet and hands pressing into the ground and the hips pushing to the sky.");

final _shoulderType3 =
    Shoulder(imageUrl: "assets/images/egalepose.jpg", name: "Eagle Arms(garudasana)", desc: "this is effectively alleviate shoulder pain by deeply stretching the muscles between the shoulder blades, promoting relaxation and reducing tension.");
final _shoulderType4 =
    Shoulder(imageUrl: "assets/images/ThreadtheNeedlePose.jpg", name: "Thread the Needle Pose", desc: "it also known as Parsva Balasana is highly effective for relieving shoulder pain. By threading one arm under the other while in a tabletop position, it deeply stretches the shoulders, upper back, and neck, helping to release tension and improve flexibility.");

final List<Shoulder> shoulderYoga = [_shoulderType1, _shoulderType2, _shoulderType3,_shoulderType4];


final _backType1 = BackPain(
    imageUrl: "assets/images/childspose.webp", name: "child's pose", desc: "By gently stretching the spine, hips, and thighs, Child's Pose helps alleviate tension in the back and neck muscles,This pose encourages deep breathing and mindfulness, aiding in stress reduction and promoting a sense of calm.");
final _backType2 = BackPain(
    imageUrl: "assets/images/adhoMukhaShavasana.png",
    name: "Adho Mukha Svanasana",
    desc: "Adho Mukha Svanasana, also known as Downward-Facing Dog, is a foundational yoga asana that requires flexibility and upper body strength. In this asana, the body forms an inverted “V” with the feet and hands pressing into the ground and the hips pushing to the sky.");

final _backType3 = BackPain(
    imageUrl: "assets/images/Bridgepose.jpg", name: "Bridge pose", desc: "It is also known as Setu Bandha Sarvangasana, is a foundational backbend in yoga that offers numerous physical and mental benefits. This pose involves lying on your back and lifting your hips towards the ceiling, creating a bridge-like shape with your body.");

final List<BackPain> backPainYoga = [
  _backType1,
  _backType2,
  _backType3
];



final _KneeType1 = KneePain(imageUrl: "assets/images/Bridgepose.jpg", name: "Bridge pose", desc: "It is also known as Setu Bandha Sarvangasana, is a foundational backbend in yoga that offers numerous physical and mental benefits. This pose involves lying on your back and lifting your hips towards the ceiling, creating a bridge-like shape with your body.");

final _KneeType2 = KneePain(imageUrl: "assets/images/chairpose.webp",name: "chair pose(utkatasana)",desc: "Utkatasana,also known as Chair Pose or Fierce Pose, is a standing asana in modern yoga as exercise. The name comes from the Sanskrit words “utkaṭa” (उत्कट) meaning “wild, frightening” and “asana” (आसन) meaning “pose”.");

final _KneeType3 = KneePain(imageUrl: "assets/images/Trianglepose.jpg", name: "Triangle pose (trikona pose)", desc: "Triangle Pose (Trikonasana) can be beneficial for knee health when practiced with proper alignment and awareness. It strengthens the muscles surrounding the knee joint, including the quadriceps and hamstrings, which provide support and stability to the knees.");

final List<KneePain> kneePainYoga = [_KneeType1, _KneeType2, _KneeType3];
