import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:note_book_flutter_app/database/helper.dart';
import 'package:note_book_flutter_app/dialog/confirmation_dialog.dart';
import 'package:note_book_flutter_app/modules/note.dart';

class NoteDetails extends StatefulWidget {
  final String titleApp;
  final Note note;
  NoteDetails(this.note, this.titleApp);

  @override
  NoteDetailsState createState() {
    return NoteDetailsState(this.note, this.titleApp);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  var prioritiesList = ["High", "Low"];
  var selected;

  var colorList = [
    "Pink",
    "Green",
    "Yellow",
    "Grey",
  ];
  var selectedCor;

  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleCon = TextEditingController();
  TextEditingController descriptionCon = TextEditingController();

  Note note;
  String titleApp;

  NoteDetailsState(this.note, this.titleApp);
  @override
  void initState() {
    super.initState();
    selected = prioritiesList[0];
    selectedCor = colorList[0];
  }

  @override
  Widget build(BuildContext context) {
    titleCon.text = this.note.noteTitle;
    descriptionCon.text = this.note.noteDescription;

    TextStyle txtStyle = Theme.of(context).textTheme.subtitle2;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            title: Text(
              titleApp,
              style: txtStyle,
            ),
          ),
          body: ListView(
            children: <Widget>[
              Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text("Color: "),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child:
                            createDropDownButtonColor(colorList, selectedCor),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text("Priority:"),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: createDropDownButton(prioritiesList, selected),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: createTextFormField("Heading",
                    "Enter Title of your node", txtStyle, titleCon, 2),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: createTextFormField(
                    "Description",
                    "Enter Description of your node",
                    txtStyle,
                    descriptionCon,
                    5),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: createButton("Save!"),
                    ),
                    Container(
                      width: 15.0,
                    ),
                    Expanded(
                      child: createButton("Delete!"),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget createDropDownButton(List<String> menue, String selected) {
    return DropdownButton<String>(
      items: menue.map((String item) {
        return DropdownMenuItem(
          value: item, // Traverse the whole list!
          child: Text(item),
        );
      }).toList(),
      value: getPriorityAsString(this.note.notePriority),
      onChanged: (String newSelectedValue) {
        setState(() {
          updatePriorityAsInt(newSelectedValue);
        });
      },
    );
  }

  Widget createDropDownButtonColor(List<String> menue, String selected) {
    return DropdownButton<String>(
      items: menue.map((String item) {
        return DropdownMenuItem(
          value: item, // Traverse the whole list!
          child: Text(item),
        );
      }).toList(),
      value: getColor(),
      onChanged: (String newSelectedValue) {
        setState(() {
          selectedCor = newSelectedValue;
          updateColor(selected);
        });
      },
    );
  }

  Widget createTextFormField(String label, String hint, TextStyle txtStyle,
      var controller, int maxLines) {
    return TextFormField(
      maxLines: maxLines,
      controller: controller,
      cursorColor: Colors.pink,
      style: txtStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      onChanged: (value) {
        if (label == "Heading") {
          debugPrint("************ZFT!!*************");
          updateTitle();
        } else {
          updateDescription();
        }
      },
    );
  }

  Widget createButton(var textButton) {
    return RaisedButton(
      color: Colors.pinkAccent,
      textColor: Theme.of(context).primaryColor,
      child: Text(
        textButton,
        textScaleFactor: 1.5,
      ),
      onPressed: () {
        setState(() {
          if (textButton == "Save!") {
            //debugPrint("Iam On set State!!!!!");

            _save();
          } else if (textButton == "Delete!") {
            if (this.note.noteId == null) {
              _delete();
            } else {
              var res = showDialog(
                  context: context,
                  builder: (context) => ExitConfirmationDialog());

              setState(() {
                res.then((value) {
                  if (value == true) {
                    _delete();
                  }
                });
              });
            }
          }
        });
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save() async {
    moveToLastScreen();

    // note.noteDate = DateFormat.yMMMd().format(DateTime.now());
    note.noteDate = DateFormat.yMMMMEEEEd().format(DateTime.now());
    int result;
    if (note.noteId != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      //debugPrint("***********************************");
      //debugPrint(note.noteDescription);

      result = await helper.insertNote(note);
      debugPrint("Ana rg3t!!");
      debugPrint(result.toString());
    }

    if (result != 0) {
      // Success

      //listt.add("Status: Note Saved Successfully");
      //showSnackBar(context, "Status: Note Saved Successfully");
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      //listt.add("Problem Saving Note");
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
      //showSnackBar(context, 'Problem Saving Note');
    }
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.noteId == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.noteId);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.notePriority = 1;
        break;
      case 'Low':
        note.notePriority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = prioritiesList[0]; // 'High'
        break;
      case 2:
        priority = prioritiesList[1]; // 'Low'
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.noteTitle = titleCon.text;
  }

  void updateColor(String color) {
    this.note.noteColor = color;
  }

  // Update the description of Note object
  void updateDescription() {
    note.noteDescription = descriptionCon.text;
    debugPrint("******Description*******");
    debugPrint(note.noteDescription);
  }

  String getColorAsString(int noteColor) {
    String color;
    switch (noteColor) {
      case 1:
        color = colorList[0];
        break;
      case 2:
        color = colorList[1];
        break;
    }
    return color;
  }

  String getColor() {
    if (note.noteId == null) {
      return selectedCor;
    } else {
      return note.noteColor;
    }
  }
}