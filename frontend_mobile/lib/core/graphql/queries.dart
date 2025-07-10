class GraphQLQueries {
  // Auth Mutations
  static const String loginMutation = """
    mutation Login(\$email: String!, \$password: String!) {
      login(data: {email: \$email, password: \$password}) {
        id
        email
      }
    }
  """;

  static const String registerMutation = """
    mutation Register(\$email: String!, \$password: String!) {
      createUser(data: {email: \$email, password: \$password}) {
        id
        email
      }
    }
  """;

  static const String findOrCreateUserMutation = """
    mutation FindOrCreateUser(\$email: String!, \$password: String!) {
      findOrCreateUser(data: {email: \$email, password: \$password}) {
        id
        email
      }
    }
  """;

  // Notes Queries
  static const String getNotesQuery = """
    query GetNotes {
      getAllNotes {
        id
        title
        content
        createdAt
        updatedAt
        user {
          id
          email
        }
      }
    }
  """;

  static const String searchNotesQuery = """
    query SearchNotes(\$filter: SearchNoteInput!) {
      searchNotes(filter: \$filter) {
        id
        title
        content
        createdAt
        updatedAt
        user {
          id
          email
        }
      }
    }
  """;

  static const String getNoteQuery = """
    query GetNote(\$id: String!) {
      note(id: \$id) {
        id
        title
        content
        createdAt
        updatedAt
        user {
          id
          email
        }
      }
    }
  """;

  static const String createNoteMutation = """
    mutation CreateNote(\$title: String!, \$content: String!, \$userId: String!) {
      createNote(data: {title: \$title, content: \$content, userId: \$userId}) {
        id
        title
        content
        createdAt
        updatedAt
        user {
          id
          email
        }
      }
    }
  """;

  static const String updateNoteMutation = """
    mutation UpdateNote(\$id: String!, \$title: String, \$content: String) {
      updateNote(data: {id: \$id, title: \$title, content: \$content}) {
        success
        updatedId
      }
    }
  """;

  static const String deleteNoteMutation = """
    mutation DeleteNote(\$id: String!) {
      deleteNote(data: {id: \$id}) {
        success
        deletedId
      }
    }
  """;
}
