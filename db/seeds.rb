# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Clear all existing data
puts "Clearing existing data. . ."
Answer.delete_all
Question.delete_all
Registration.delete_all
Course.delete_all
User.delete_all
puts "Existing data removed."

# Create a teacher
teacher = User.create(
  first_name: "John",
  last_name: "Doe",
  email: "teacher@ska.com",
  password: "111111",
  role: :teacher
)

# Create a student
student = User.create(
  first_name: "Shawn",
  last_name: "Sutherland",
  email: "shawnsutherland@hotmail.com",
  password: "111111",
  role: :student
)

# Example trivia questions and answers
trivia_data = [
  {
    title: "General Knowledge",
    description: "General knowledge trivia questions",
    questions: [
      {
        content: "What is the capital of France?",
        answers: [
          { content: "Paris", correct: true },
          { content: "London", correct: false },
          { content: "Berlin", correct: false },
          { content: "Madrid", correct: false }
        ]
      },
      {
        content: "Who wrote 'Romeo and Juliet'?",
        answers: [
          { content: "William Shakespeare", correct: true },
          { content: "Charles Dickens", correct: false },
          { content: "Leo Tolstoy", correct: false },
          { content: "Mark Twain", correct: false }
        ]
      },
    ]
  },
  {
    title: "Science",
    description: "Science trivia questions",
    questions: [
      {
        content: "What is the chemical symbol for water?",
        answers: [
          { content: "H2O", correct: true },
          { content: "O2", correct: false },
          { content: "CO2", correct: false },
          { content: "NaCl", correct: false }
        ]
      },
      {
        content: "What planet is known as the Red Planet?",
        answers: [
          { content: "Mars", correct: true },
          { content: "Venus", correct: false },
          { content: "Jupiter", correct: false },
          { content: "Saturn", correct: false }
        ]
      },
    ]
  },
  {
    title: "History",
    description: "History trivia questions",
    questions: [
      {
        content: "Who was the first President of the United States?",
        answers: [
          { content: "George Washington", correct: true },
          { content: "Thomas Jefferson", correct: false },
          { content: "Abraham Lincoln", correct: false },
          { content: "John Adams", correct: false }
        ]
      },
      {
        content: "In which year did the Titanic sink?",
        answers: [
          { content: "1912", correct: true },
          { content: "1905", correct: false },
          { content: "1920", correct: false },
          { content: "1898", correct: false }
        ]
      },
    ]
  },
  {
    title: "Geography",
    description: "Geography trivia questions",
    questions: [
      {
        content: "Which country has the largest land area?",
        answers: [
          { content: "Russia", correct: true },
          { content: "Canada", correct: false },
          { content: "China", correct: false },
          { content: "United States", correct: false }
        ]
      },
      {
        content: "What is the longest river in the world?",
        answers: [
          { content: "Nile", correct: true },
          { content: "Amazon", correct: false },
          { content: "Yangtze", correct: false },
          { content: "Mississippi", correct: false }
        ]
      },
    ]
  },
  {
    title: "Entertainment",
    description: "Entertainment trivia questions",
    questions: [
      {
        content: "Who directed the movie 'Inception'?",
        answers: [
          { content: "Christopher Nolan", correct: true },
          { content: "Steven Spielberg", correct: false },
          { content: "James Cameron", correct: false },
          { content: "Quentin Tarantino", correct: false }
        ]
      },
      {
        content: "Which artist painted the Mona Lisa?",
        answers: [
          { content: "Leonardo da Vinci", correct: true },
          { content: "Vincent van Gogh", correct: false },
          { content: "Pablo Picasso", correct: false },
          { content: "Claude Monet", correct: false }
        ]
      },
    ]
  }
]

# Create courses, questions, and answers based on the trivia data
trivia_data.each_with_index do |course_data, course_index|
  course = Course.create(
    title: course_data[:title],
    description: course_data[:description],
    teacher_id: teacher.id
  )

  course_data[:questions].each_with_index do |question_data, question_index|
    question = Question.create(
      content: question_data[:content],
      question_type: "multiple_choice",
      course_id: course.id
    )

    question_data[:answers].each do |answer_data|
      Answer.create(
        content: answer_data[:content],
        correct: answer_data[:correct],
        question_id: question.id
      )
    end
  end
end

puts "Seed data with demo questions created successfully!"
