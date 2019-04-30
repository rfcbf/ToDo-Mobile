import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'service.dart';
import 'Todo.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      accentColor: Colors.amber,
      hintColor: Colors.amber,
      primaryColor: Colors.amberAccent,
    ),
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
        title: Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amber[400],
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.error,
              color: Colors.white,
            ),
            onPressed: () {
              _showDialogInfo(context);
            },
          ),
        ],
      ),
      body: buildTela(context),
    );
  }

  Widget buildTela(BuildContext context) {
    return Container(
//      color: Colors.amber[100],
      child: Column(
        children: <Widget>[
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
          Container(
//            color: Colors.amber[100],
            padding: EdgeInsetsDirectional.only(bottom: 20.0),
            child: FloatingActionButton(
                elevation: 4.0,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.amber[400],
                onPressed: () {
                  _showDialog(context);
                }),
          ),
        ],
      ),
    );
  }

  Widget buildList() {
    return Container(
//      color: Colors.amber[100],
      child: ListView.builder(
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
                activeColor: Colors.green,
                title: Text(todos[index].texto),
                value: todos[index].concluido,
                secondary: todos[index].concluido
                    ? CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check),
                      )
                    : CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.error),
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
          }),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: _toDoController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.amber)),
                    fillColor: Colors.amber,
                    labelStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.amber,
                        decorationColor: Colors.amber),
                    labelText: 'Nova Tarefa:',
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Adicionar'),
                onPressed: () {
                  if (_toDoController != null && _toDoController.text != '' && _toDoController.text != null){
                    _addToDo();
                    Navigator.pop(context);
                  }
                }),
          ],
        );
      },
    );
  }

  _showDialogInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sobre',
          ),
          content: Container(
            child: new Text(
                'Desenvolvido por: Renato Ferraz\nVersão: 2.0\n\nDesafio da ESIG'),
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('Fechar'),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}
