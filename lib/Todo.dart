class Todo {

  int id;
  String texto;
  bool concluido;

  Todo(int id, String texto, bool concluido) {
    this.id = id;
    this.texto = texto;
    this.concluido = concluido;
  }

  Todo.fromJson(Map json)
      : id = json['id'],
        texto = json['texto'],
        concluido = json['concluido'];

  Map toJson() {
    return {'id': id, 'texto': texto, 'concluido': concluido};
  }
}