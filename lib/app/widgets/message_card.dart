// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gal/gal.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../core/export.dart';
// import '../domain/export.dart';
// import '../utils/exports.dart';
//
// class MessageCard extends StatefulWidget {
//   final Message message;
//   final bool pause;
//
//   const MessageCard({
//     super.key,
//     required this.message,
//     required this.pause,
//   });
//
//   @override
//   State<MessageCard> createState() => _MessageCardState();
// }
//
// class _MessageCardState extends State<MessageCard> {
//   bool isHovered = false;
//   final useCase = Get.find<UserManagementUseCase>();
//
//   @override
//   Widget build(BuildContext context) {
//     Size chatMq = MediaQuery.of(context).size;
//     bool isMe = useCase.getUserId().toString() == widget.message.fromId;
//     if (widget.message.read.isEmpty && !widget.pause) {
//       FirebaseService.updateMessageReadStatus(widget.message);
//     }
//     return InkWell(
//       onLongPress: () {
//         _showBottomSheet(context: context, message: widget.message, isMe: isMe);
//         FocusScope.of(context).unfocus();
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           Flexible(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: chatMq.width * .85),
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   vertical: chatMq.height * .01,
//                   horizontal: widget.message.type == Type.image
//                       ? chatMq.width * .02
//                       : chatMq.width * .03,
//                 ),
//                 margin: EdgeInsets.symmetric(
//                   horizontal: chatMq.width * .03,
//                   vertical: chatMq.height * .01,
//                 ),
//                 decoration: BoxDecoration(
//                   color:
//                       isMe ? AppColors.secondaryColor : const Color(0xFFF5F6FA),
//                   borderRadius: BorderRadius.only(
//                     topRight: const Radius.circular(15),
//                     topLeft: const Radius.circular(15),
//                     bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
//                     bottomRight: isMe ? Radius.zero : const Radius.circular(15),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment:
//                       isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     widget.message.type == Type.text
//                         ? Text(
//                             widget.message.msg,
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               color: isMe ? Colors.white : Colors.black,
//                               // fontFamily: "Google Font",
//                             ),
//                           )
//                         : ClipRRect(
//                             borderRadius: BorderRadius.circular(15),
//                             child: CachedNetworkImage(
//                               imageUrl: widget.message.msg,
//                               errorWidget: (c, url, e) => const Icon(
//                                   size: 70, Icons.image, color: Colors.black),
//                               placeholder: (c, url) => const Padding(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                     const SizedBox(height: 04),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           MyDateUtill.getFormatedTime(
//                             context: context,
//                             time: widget.message.sent,
//                           ),
//                           style: GoogleFonts.poppins(
//                             fontSize: 10,
//                             color: isMe ? Colors.white : Colors.black54,
//                           ),
//                         ),
//                         if (isMe) const SizedBox(width: 7),
//                         if (isMe)
//                           Icon(
//                             Icons.done_all_rounded,
//                             color: widget.message.read.isNotEmpty
//                                 ? Colors.blue
//                                 : Colors.black54,
//                             size: 16,
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showBottomSheet({
//     required BuildContext context,
//     required Message message,
//     required bool isMe,
//   }) {
//     Size chatMq = MediaQuery.of(context).size;
//     var shit = chatMq.width * .04;
//     showModalBottomSheet(
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       context: context,
//       showDragHandle: true,
//       backgroundColor: AppColors.whiteColor,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(25), topRight: Radius.circular(25))),
//       builder: (context) {
//         return ListView(
//           shrinkWrap: true,
//           children: [
//             message.type == Type.image
//                 // save image option
//                 ? _OptionItem(
//                     icon: const Icon(Icons.download_rounded,
//                         color: Colors.blue, size: 26),
//                     name: 'Save Image',
//                     onTap: () async {
//                       try {
//                         final path = Directory.systemTemp.path;
//                         await Dio().download(message.msg, path);
//                         await Gal.putImage(path).then(
//                           (s) {
//                             Navigator.pop(context);
//                             AppUtils.successData(
//                               title: "Image",
//                               message: 'Image Saved Successfully !!',
//                             );
//                           },
//                         );
//                       } on GalException catch (e) {
//                         AppUtils.failedData(
//                           title: "Error",
//                           message: e.type.message,
//                         );
//                       } catch (e) {
//                         AppUtils.failedData(
//                           title: "Error",
//                           message:
//                               'Image couldn\'t be saved, please try again.',
//                         );
//                       }
//                     },
//                   )
//                 // copy option
//                 : _OptionItem(
//                     icon: const Icon(Icons.copy_all_rounded,
//                         color: Colors.blue, size: 26),
//                     name: 'Copy Message',
//                     onTap: () async {
//                       await Clipboard.setData(ClipboardData(text: message.msg))
//                           .then((value) {
//                         Navigator.pop(context);
//                         AppUtils.successData(
//                           title: "Copy",
//                           message: 'Message Copied!',
//                         );
//                       });
//                     },
//                   ),
//             // spacer(line)
//             if (isMe)
//               Divider(
//                 color: Colors.black54,
//                 endIndent: shit,
//                 indent: shit,
//               ),
//             // edit message if text
//             if (message.type == Type.text && isMe)
//               _OptionItem(
//                 icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
//                 name: 'Edit Message',
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showMessageUpdateDialogue(
//                     context: context,
//                     message: message,
//                   );
//                 },
//               ),
//             // delete message
//             if (isMe)
//               _OptionItem(
//                 icon: const Icon(Icons.delete, color: Colors.red, size: 26),
//                 name: message.type == Type.text
//                     ? 'Delete Message'
//                     : 'Delete image',
//                 onTap: () async {
//                   await FirebaseService.deleteMessage(message).then((value) {
//                     Navigator.pop(context);
//                     AppUtils.successData(
//                       title: "Deleted",
//                       message: 'Message Deleted!',
//                     );
//                   });
//                 },
//               ),
//             // spacer(line)
//             Divider(
//               color: Colors.black54,
//               endIndent: shit,
//               indent: shit,
//             ),
//             // sent at
//             _OptionItem(
//               icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
//               name:
//                   'Sent At: ${MyDateUtill.getMessageTime(context: context, time: message.sent)}',
//               onTap: () {},
//             ),
//             // read at
//             _OptionItem(
//               icon: const Icon(Icons.remove_red_eye, color: Colors.green),
//               name: message.read.isEmpty
//                   ? 'Read At: Not seen yet'
//                   : 'Read At: ${MyDateUtill.getMessageTime(context: context, time: message.read)}',
//               onTap: () {},
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future _showMessageUpdateDialogue(
//       {required BuildContext context, required Message message}) async {
//     String updatedMsg = message.msg;
//     return await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         actionsAlignment: MainAxisAlignment.spaceEvenly,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         contentPadding:
//             const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
//         actionsPadding: kIsWeb ? const EdgeInsets.only(bottom: 10) : null,
//         title: const Row(
//           children: [
//             Icon(
//               Icons.message,
//               color: Colors.blue,
//               size: 26,
//             ),
//             Text('  Update Message'),
//           ],
//         ),
//         content: Container(
//           constraints: kIsWeb
//               ? BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .5)
//               : null,
//           child: TextFormField(
//             initialValue: updatedMsg,
//             maxLines: null,
//             // style: const TextStyle(fontFamily: "Google Font"),
//             onChanged: (value) => updatedMsg = value,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           MaterialButton(
//             onPressed: () => Navigator.pop(_),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           Container(
//             width: 2,
//             height: 20,
//             decoration: BoxDecoration(
//                 color: Colors.grey, borderRadius: BorderRadius.circular(10)),
//           ),
//           MaterialButton(
//             onPressed: () async {
//               Navigator.pop(_);
//               await FirebaseService.updateMessage(message, updatedMsg);
//             },
//             child: const Text(
//               'Update',
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _OptionItem extends StatelessWidget {
//   final Icon icon;
//   final String name;
//   final void Function()? onTap;
//
//   const _OptionItem({
//     required this.icon,
//     required this.name,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Size chatMq = MediaQuery.of(context).size;
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: kIsWeb
//             ? EdgeInsets.zero
//             : EdgeInsets.only(
//                 left: chatMq.width * .05,
//                 top: chatMq.height * .01,
//                 bottom: chatMq.height * .01,
//               ),
//         child: Row(
//           children: [
//             icon,
//             Flexible(
//               child: Text(
//                 '   $name',
//                 style: const TextStyle(
//                   color: Colors.black54,
//                   fontSize: 15,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
