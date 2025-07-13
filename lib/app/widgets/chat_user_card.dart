// import 'package:asan_rishta/widgets/app_text.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../core/export.dart';
// import '../screens/chat/chatting_view.dart';
// import '../utils/exports.dart';
//
// class ChatUserCard extends StatefulWidget {
//   final String currentUID;
//   final ChatUser user;
//
//   const ChatUserCard({
//     super.key,
//     required this.user,
//     required this.currentUID,
//   });
//
//   @override
//   State<ChatUserCard> createState() => _ChatUserCardState();
// }
//
// class _ChatUserCardState extends State<ChatUserCard> {
//   Message? _message;
//
//   @override
//   Widget build(BuildContext context) {
//     Size mobileMq = MediaQuery.of(context).size;
//     return Card(
//       color: const Color(0xFFF6F6F6),
//       margin: EdgeInsets.symmetric(
//         horizontal: mobileMq.width * .03,
//         vertical: 4,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: InkWell(
//         onTap: () {
//           Get.to(
//             () => ChattingView(user: widget.user),
//           )!
//               .then((onValue) async {
//             await FirebaseService.insideChatStatus(false);
//           });
//         },
//         child: StreamBuilder(
//           stream: FirebaseService.getLastMessage(widget.user),
//           builder: (context, snapshot) {
//             final data = snapshot.data?.docs;
//             final list =
//                 data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
//             if (list.isNotEmpty) _message = list[0];
//             return ListTile(
//               leading: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundColor: Colors.transparent,
//                     foregroundImage: provider(),
//                   ),
//                   if (widget.user.isOnline)
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: greenCircle(),
//                     ),
//                 ],
//               ),
//
//               //user name
//               title: Text(widget.user.name),
//
//               //last message
//               subtitle: _message != null
//                   ? _message!.type == Type.image
//                       ? _message!.fromId == widget.currentUID
//                           ? Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 doubleTickIcon(),
//                                 const SizedBox(width: 7),
//                                 const Icon(Icons.image_rounded,
//                                     color: Colors.black38, size: 20),
//                                 text(' Photo'),
//                               ],
//                             )
//                           : Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(Icons.image_rounded,
//                                     color: Colors.black38, size: 20),
//                                 text(' Photo'),
//                               ],
//                             )
//                       : _message!.fromId == widget.currentUID
//                           ? Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 doubleTickIcon(),
//                                 const SizedBox(width: 7),
//                                 // actual msg
//                                 Flexible(
//                                   child: Text(
//                                     _message!.msg,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : text(_message!.msg)
//                   : text(widget.user.about),
//
//               //last message time
//               trailing: lastSeen(_message),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   ImageProvider? provider() {
//     if (widget.user.image.isEmpty) return const NetworkImage(AppConstants.profileImg);
//     if (widget.user.image.isNotEmpty) return NetworkImage(widget.user.image);
//     return const NetworkImage(AppConstants.profileImg);
//   }
//
//   lastSeen(Message? message) {
//     return message == null
//         ? null
//         : message.read.isEmpty && message.fromId != widget.currentUID
//             ? greenCircle()
//             : text(
//                 MyDateUtill.getLastMessageTime(
//                   context,
//                   message.sent,
//                 ),
//               );
//   }
//
//   Widget text(String text) {
//     return AppText(
//       text: text,
//       overflow: TextOverflow.ellipsis,
//       fontSize: 14,
//     );
//   }
//
//   Widget doubleTickIcon() {
//     return Icon(
//       Icons.done_all_rounded,
//       color: _message!.read.isEmpty ? Colors.black38 : Colors.blue,
//       size: 20,
//     );
//   }
//
//   Widget greenCircle() {
//     return Container(
//       height: 10,
//       width: 10,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.lightGreenAccent[400]),
//     );
//   }
// }
