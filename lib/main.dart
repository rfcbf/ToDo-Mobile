import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'service.dart';
import 'Todo.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List<Todo> todos = [];

  Future<String> _getData() async {
    await service.getTodo(http.Client()).then((response) {
      todos = response;
    });

    return 'sucesso';
  }

  void _addToDo() async {
    await service.post(_toDoController.text);
    _toDoController.text = "";
    setState(() {
      _getData();
    });


  }

  void _excluirTodo(String id) async {
    await service.delete(id);
    setState(() {
      _getData();
    });
  }

  void _atualizaStatus(String id) async {
    await service.update(id);
    setState(() {
      _getData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _getData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: buildTela());
  }

  Widget buildTela() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                controller: _toDoController,
                decoration: InputDecoration(
                    labelText: "Nova Tarefa",
                    labelStyle: TextStyle(color: Colors.blueAccent)),
              )),
              RaisedButton(
                color: Colors.blueAccent,
                child: Text("Adicionar"),
                textColor: Colors.white,
                onPressed: _addToDo,
              )
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder(
              future: _getData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? buildList() //buildList(snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildList() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
            background: Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment(-0.9, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            direction: DismissDirection.startToEnd,
            child: CheckboxListTile(
              title: Text(todos[index].texto),
              value: todos[index].concluido,
              secondary: CircleAvatar(
                child: Icon(todos[index].concluido ? Icons.check : Icons.error),
              ),
              onChanged: (c) {
                todos[index].concluido = c;
                _atualizaStatus(todos[index].id.toString());
              },
            ),
            onDismissed: (direction) {
              _excluirTodo(todos[index].id.toString());
              todos.removeAt(index);
            },
          );
        });
  }
}
