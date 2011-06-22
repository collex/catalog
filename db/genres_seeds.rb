Genre.delete_all()

genres = [ "Architecture",
        "Artifacts", "Bibliography",
        "Collection", "Criticism", "Drama",
        "Education", "Ephemera", "Fiction",
        "History", "Leisure", "Letters",
        "Life Writing", "Manuscript", "Music",
        "Nonfiction", "Paratext", "Periodical",
        "Philosophy", "Photograph", "Poetry",
        "Religion", "Review", "Science",
        "Translation", "Travel",
        "Visual Art", "Citation",
        "Book History", "Family Life", "Folklore",
        "Humor", "Law", "Reference Works", "Sermon" ]

genres.each { |genre|
	Genre.create!({ :name => genre })
}
