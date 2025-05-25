import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manpower/mobile/freelancer/home_freelancer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ApplyProposal extends StatefulWidget {
  final String jobId;
  const ApplyProposal({super.key, required this.jobId});

  @override
  State<ApplyProposal> createState() => _ApplyProposalState();
}

class _ApplyProposalState extends State<ApplyProposal> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  String? _fileName;
  String? _fileUrl;
  String? _fileKey;
  bool _isLoading = false;
  String? _paymentType;
  double? _youWillReceive;

  @override
  void initState() {
    super.initState();
    _fetchPaymentType();
  }

  Future<void> _fetchPaymentType() async {
    final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
    final paymentType = jobDoc['paymentType'] as String;
    setState(() {
      _paymentType = paymentType;
    });
  }

  void _calculateServiceFee(String value) {
    final rate = double.tryParse(value);
    if (rate != null) {
      final fee = rate * 0.10;
      final receive = rate - fee;
      setState(() {
        _youWillReceive = receive;
      });
    }
  }

  Future<void> _uploadFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    if (filePickerResult != null) {
      final fileName = filePickerResult.files.single.name;
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final fileKey = '$uid/$fileName';

      final storage = sb.Supabase.instance.client.storage.from('files');

      try {
        if (kIsWeb) {
          final Uint8List fileBytes = filePickerResult.files.single.bytes!;
          await storage.uploadBinary(fileKey, fileBytes);
        } else {
          final String filePath = filePickerResult.files.single.path!;
          final io.File file = io.File(filePath);
          await storage.upload(fileKey, file);
        }

        final publicUrl = storage.getPublicUrl(fileKey);

        setState(() {
          _fileName = fileName;
          _fileKey = fileKey;
          _fileUrl = publicUrl;
        });
      } catch (e) {
        print('Upload failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File upload failed')));
      }
    }
  }

  Future<void> _submitProposal() async {
    final message = _messageController.text.trim();
    final rateText = _rateController.text.trim();
    final rate = double.tryParse(rateText);

    if (message.isEmpty || rate == null || _fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete all fields and upload a file')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final proposal = {
        'jobId': widget.jobId,
        'message': message,
        'rate': rate,
        'fileName': _fileName,
        'fileUrl': _fileUrl,
        'fileKey': _fileKey,
        'userId': uid,
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('proposals')
          .add(proposal);

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .collection('proposals')
          .add(proposal);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proposal submitted!')));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeFreelancer()), (route) => false);
    } catch (e) {
      print('Proposal submit failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit failed')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Apply for Job', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _submitProposal,
        label: Text('Apply for this Job'),
        icon: Icon(Icons.send),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_paymentType != null)
              Text(
                _paymentType == 'fixed'
                    ? 'What is the fixed price you would like for this job?'
                    : 'What is the rate you would like to bid (per hour)?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              onChanged: _calculateServiceFee,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 12),
            if (_youWillReceive != null)
              Text(
                'You will receive: \$${_youWillReceive!.toStringAsFixed(2)} (after 10% service fee)',
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
              ),
            const SizedBox(height: 20),
            Text('Cover Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your proposal message here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Upload File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Column(
              children: [
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _uploadFile,
                    icon: Icon(Icons.upload_file, color: Colors.white,),
                    label: Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width *.75, 40),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_fileName != null)
                  Center(child: Text(_fileName!, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
