# Clear all existing data
puts "Clearing existing data. . ."
ActiveRecord::Base.connection.execute("DELETE FROM attempts_answers")
Attempt.delete_all
Answer.delete_all
Question.delete_all
Registration.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM group_courses")
Course.delete_all
GroupMembership.delete_all
Group.delete_all
Subscription.delete_all
Membership.delete_all
User.delete_all
Level.delete_all
puts "Existing data removed."

# Create teachers
teacher = User.create(
  first_name: "Shawn",
  last_name: "Sutherland",
  email: "shawnsutherland@hotmail.com",
  password: "111111",
  role: :teacher
)

roel = User.create(
  first_name: "Roel",
  last_name: "de Jong",
  email: "roel4811@gmail.com",
  password: "111111",
  role: :teacher
)

nour = User.create(
  first_name: "Nour",
  last_name: "El Ghezaoui",
  email: "nourelghezaoui@nghulp.nl",
  password: "111111",
  role: :admin
)

# Create students
student = User.create(
  first_name: "John",
  last_name: "Doe",
  email: "student@ska.com",
  password: "111111",
  role: :student
)

students = [
  {first_name: "Alice", last_name: "Johnson", email: "alice.johnson@ska.com"},
  {first_name: "Bob", last_name: "Smith", email: "bob.smith@ska.com"},
  {first_name: "Charlie", last_name: "Davis", email: "charlie.davis@ska.com"},
  {first_name: "Diana", last_name: "Evans", email: "diana.evans@ska.com"},
  {first_name: "Ethan", last_name: "Brown", email: "ethan.brown@ska.com"},
  {first_name: "Fiona", last_name: "Wilson", email: "fiona.wilson@ska.com"},
  {first_name: "George", last_name: "Miller", email: "george.miller@ska.com"},
  {first_name: "Hannah", last_name: "Garcia", email: "hannah.garcia@ska.com"},
  {first_name: "Isaac", last_name: "Martinez", email: "isaac.martinez@ska.com"},
  {first_name: "Julia", last_name: "Lee", email: "julia.lee@ska.com"}
]

students.each do |student|
  User.create!(
    first_name: student[:first_name],
    last_name: student[:last_name],
    email: student[:email],
    password: "111111",
    role: :student
  )
end

groupA = Group.create(
  name: "Group A",
  teacher: teacher
)

groupB = Group.create(
  name: "Group B",
  teacher: teacher
)

# Creating levels
puts "Creating levels... Group 3 t/m 8"
(3..7).each do |n|
  Level.create!(name: "Leerlingenlijst #{n}", order: n)
end

groupA.students << roel
groupA.students << nour

groupB.students << roel
groupB.students << nour

# Example trivia questions and answers
trivia_data = [
  {
    title: "General Knowledge",
    description: "General knowledge trivia questions",
    questions: [
      {
        content: "What is the capital of France?",
        question_type: "multiple_choice",
        answers: [
          {content: "Paris", correct: true},
          {content: "London", correct: false},
          {content: "Berlin", correct: false},
          {content: "Madrid", correct: false}
        ]
      },
      {
        content: "Who wrote 'Romeo and Juliet'?",
        question_type: "multiple_choice",
        answers: [
          {content: "William Shakespeare", correct: true},
          {content: "Charles Dickens", correct: false},
          {content: "Leo Tolstoy", correct: false},
          {content: "Mark Twain", correct: false}
        ]
      },
      {
        content: "What is 5 + 7?",
        question_type: "open_answer",
        correct_answer: "12"
      },
      {
        content: "Which element has the chemical symbol 'O'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Oxygen", correct: true},
          {content: "Gold", correct: false},
          {content: "Osmium", correct: false},
          {content: "Oganesson", correct: false}
        ]
      },
      {
        content: "Which planet is known as the 'Morning Star'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Venus", correct: true},
          {content: "Mars", correct: false},
          {content: "Mercury", correct: false},
          {content: "Saturn", correct: false}
        ]
      },
      {
        content: "The Earth is flat.",
        question_type: "true_false",
        answers: [
          {content: "True", correct: false},
          {content: "False", correct: true}
        ]
      },
      {
        content: "In which year did the Berlin Wall fall?",
        question_type: "multiple_choice",
        answers: [
          {content: "1989", correct: true},
          {content: "1991", correct: false},
          {content: "1985", correct: false},
          {content: "1979", correct: false}
        ]
      },
      {
        content: "What is the largest mammal in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Blue Whale", correct: true},
          {content: "Elephant", correct: false},
          {content: "Giraffe", correct: false},
          {content: "Hippopotamus", correct: false}
        ]
      },
      {
        content: "Which of these are primary colors?",
        question_type: "multiple_answer",
        answers: [
          {content: "Red", correct: true},
          {content: "Green", correct: false},
          {content: "Blue", correct: true},
          {content: "Yellow", correct: true}
        ]
      },
      {
        content: "How many continents are there on Earth?",
        question_type: "multiple_choice",
        answers: [
          {content: "Seven", correct: true},
          {content: "Five", correct: false},
          {content: "Six", correct: false},
          {content: "Eight", correct: false}
        ]
      },
      {
        content: "What is the hardest natural substance on Earth?",
        question_type: "multiple_choice",
        answers: [
          {content: "Diamond", correct: true},
          {content: "Gold", correct: false},
          {content: "Iron", correct: false},
          {content: "Graphite", correct: false}
        ]
      },
      {
        content: "What is the smallest country in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Vatican City", correct: true},
          {content: "Monaco", correct: false},
          {content: "San Marino", correct: false},
          {content: "Liechtenstein", correct: false}
        ]
      },
      {
        content: "What is the longest river in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Nile", correct: true},
          {content: "Amazon", correct: false},
          {content: "Yangtze", correct: false},
          {content: "Mississippi", correct: false}
        ]
      }
    ]
  },
  {
    title: "Science",
    description: "Science trivia questions",
    questions: [
      {
        content: "What is the chemical symbol for water?",
        question_type: "multiple_choice",
        answers: [
          {content: "H2O", correct: true},
          {content: "O2", correct: false},
          {content: "CO2", correct: false},
          {content: "NaCl", correct: false}
        ]
      },
      {
        content: "What is the freezing point of water in Celsius?",
        question_type: "open_answer",
        correct_answer: "0"
      },
      {
        content: "What planet is known as the Red Planet?",
        question_type: "multiple_choice",
        answers: [
          {content: "Mars", correct: true},
          {content: "Venus", correct: false},
          {content: "Jupiter", correct: false},
          {content: "Saturn", correct: false}
        ]
      },
      {
        content: "What is the most abundant gas in the Earth's atmosphere?",
        question_type: "multiple_choice",
        answers: [
          {content: "Nitrogen", correct: true},
          {content: "Oxygen", correct: false},
          {content: "Carbon Dioxide", correct: false},
          {content: "Hydrogen", correct: false}
        ]
      },
      {
        content: "Water boils at 100 degrees Celsius.",
        question_type: "true_false",
        answers: [
          {content: "True", correct: true},
          {content: "False", correct: false}
        ]
      },
      {
        content: "Which planet is closest to the sun?",
        question_type: "multiple_choice",
        answers: [
          {content: "Mercury", correct: true},
          {content: "Venus", correct: false},
          {content: "Earth", correct: false},
          {content: "Mars", correct: false}
        ]
      },
      {
        content: "What is the human body's largest organ?",
        question_type: "multiple_choice",
        answers: [
          {content: "Skin", correct: true},
          {content: "Heart", correct: false},
          {content: "Liver", correct: false},
          {content: "Lungs", correct: false}
        ]
      },
      {
        content: "How many bones are there in the adult human body?",
        question_type: "multiple_choice",
        answers: [
          {content: "206", correct: true},
          {content: "195", correct: false},
          {content: "210", correct: false},
          {content: "215", correct: false}
        ]
      },
      {
        content: "What force keeps us anchored to the Earth?",
        question_type: "multiple_choice",
        answers: [
          {content: "Gravity", correct: true},
          {content: "Magnetism", correct: false},
          {content: "Friction", correct: false},
          {content: "Electromagnetism", correct: false}
        ]
      },
      {
        content: "What is the powerhouse of the cell?",
        question_type: "multiple_choice",
        answers: [
          {content: "Mitochondria", correct: true},
          {content: "Nucleus", correct: false},
          {content: "Ribosome", correct: false},
          {content: "Golgi apparatus", correct: false}
        ]
      },
      {
        content: "Which element is the most abundant in the Earth's crust?",
        question_type: "multiple_choice",
        answers: [
          {content: "Oxygen", correct: true},
          {content: "Silicon", correct: false},
          {content: "Aluminum", correct: false},
          {content: "Iron", correct: false}
        ]
      },
      {
        content: "What is the speed of light?",
        question_type: "multiple_choice",
        answers: [
          {content: "299,792,458 meters per second", correct: true},
          {content: "150,000,000 meters per second", correct: false},
          {content: "1,000,000 meters per second", correct: false},
          {content: "3,000,000 meters per second", correct: false}
        ]
      }
    ]
  },
  {
    title: "History",
    description: "History trivia questions",
    questions: [
      {
        content: "Who was the first President of the United States?",
        question_type: "multiple_choice",
        answers: [
          {content: "George Washington", correct: true},
          {content: "Thomas Jefferson", correct: false},
          {content: "Abraham Lincoln", correct: false},
          {content: "John Adams", correct: false}
        ]
      },
      {
        content: "Select all the U.S. Presidents from the list:",
        question_type: "multiple_answer",
        answers: [
          {content: "George Washington", correct: true},
          {content: "Benjamin Franklin", correct: false},
          {content: "John Adams", correct: true},
          {content: "Thomas Edison", correct: false}
        ]
      },
      {
        content: "In which year did the Titanic sink?",
        question_type: "multiple_choice",
        answers: [
          {content: "1912", correct: true},
          {content: "1905", correct: false},
          {content: "1920", correct: false},
          {content: "1898", correct: false}
        ]
      },
      {
        content: "Who discovered America?",
        question_type: "multiple_choice",
        answers: [
          {content: "Christopher Columbus", correct: true},
          {content: "Ferdinand Magellan", correct: false},
          {content: "Leif Erikson", correct: false},
          {content: "James Cook", correct: false}
        ]
      },
      {
        content: "Which war was fought between the North and South regions in the United States?",
        question_type: "multiple_choice",
        answers: [
          {content: "The Civil War", correct: true},
          {content: "The Revolutionary War", correct: false},
          {content: "World War I", correct: false},
          {content: "The Korean War", correct: false}
        ]
      },
      {
        content: "Who was the first man to step on the moon?",
        question_type: "multiple_choice",
        answers: [
          {content: "Neil Armstrong", correct: true},
          {content: "Buzz Aldrin", correct: false},
          {content: "Michael Collins", correct: false},
          {content: "Yuri Gagarin", correct: false}
        ]
      },
      {
        content: "In which year did World War II end?",
        question_type: "multiple_choice",
        answers: [
          {content: "1945", correct: true},
          {content: "1939", correct: false},
          {content: "1941", correct: false},
          {content: "1949", correct: false}
        ]
      },
      {
        content: "Which empire was known as the 'Sun Never Sets' empire?",
        question_type: "multiple_choice",
        answers: [
          {content: "The British Empire", correct: true},
          {content: "The Roman Empire", correct: false},
          {content: "The Ottoman Empire", correct: false},
          {content: "The Mongol Empire", correct: false}
        ]
      },
      {
        content: "Who was the first woman to fly solo across the Atlantic Ocean?",
        question_type: "multiple_choice",
        answers: [
          {content: "Amelia Earhart", correct: true},
          {content: "Bessie Coleman", correct: false},
          {content: "Harriet Quimby", correct: false},
          {content: "Jacqueline Cochran", correct: false}
        ]
      },
      {
        content: "Which ancient civilization built the pyramids?",
        question_type: "multiple_choice",
        answers: [
          {content: "The Egyptians", correct: true},
          {content: "The Romans", correct: false},
          {content: "The Mayans", correct: false},
          {content: "The Incas", correct: false}
        ]
      },
      {
        content: "What document was signed in 1215 limiting the power of the king of England?",
        question_type: "multiple_choice",
        answers: [
          {content: "Magna Carta", correct: true},
          {content: "The Bill of Rights", correct: false},
          {content: "The Declaration of Independence", correct: false},
          {content: "The Constitution", correct: false}
        ]
      }
    ]
  },
  {
    title: "Geography",
    description: "Geography trivia questions",
    questions: [
      {
        content: "Which country has the largest land area?",
        question_type: "multiple_choice",
        answers: [
          {content: "Russia", correct: true},
          {content: "Canada", correct: false},
          {content: "China", correct: false},
          {content: "United States", correct: false}
        ]
      },
      {
        content: "What is the longest river in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Nile", correct: true},
          {content: "Amazon", correct: false},
          {content: "Yangtze", correct: false},
          {content: "Mississippi", correct: false}
        ]
      },
      {
        content: "Which country is known as the Land of the Rising Sun?",
        question_type: "multiple_choice",
        answers: [
          {content: "Japan", correct: true},
          {content: "China", correct: false},
          {content: "South Korea", correct: false},
          {content: "Thailand", correct: false}
        ]
      },
      {
        content: "What is the smallest continent by land area?",
        question_type: "multiple_choice",
        answers: [
          {content: "Australia", correct: true},
          {content: "Europe", correct: false},
          {content: "Antarctica", correct: false},
          {content: "South America", correct: false}
        ]
      },
      {
        content: "Which ocean is the largest?",
        question_type: "multiple_choice",
        answers: [
          {content: "Pacific Ocean", correct: true},
          {content: "Atlantic Ocean", correct: false},
          {content: "Indian Ocean", correct: false},
          {content: "Arctic Ocean", correct: false}
        ]
      },
      {
        content: "Which is the tallest mountain in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Mount Everest", correct: true},
          {content: "K2", correct: false},
          {content: "Kangchenjunga", correct: false},
          {content: "Lhotse", correct: false}
        ]
      },
      {
        content: "Which desert is the largest in the world?",
        question_type: "multiple_choice",
        answers: [
          {content: "Sahara Desert", correct: true},
          {content: "Gobi Desert", correct: false},
          {content: "Kalahari Desert", correct: false},
          {content: "Atacama Desert", correct: false}
        ]
      },
      {
        content: "Which river flows through Paris?",
        question_type: "multiple_choice",
        answers: [
          {content: "Seine", correct: true},
          {content: "Thames", correct: false},
          {content: "Danube", correct: false},
          {content: "Rhine", correct: false}
        ]
      },
      {
        content: "Which country is the most populous?",
        question_type: "multiple_choice",
        answers: [
          {content: "China", correct: true},
          {content: "India", correct: false},
          {content: "United States", correct: false},
          {content: "Indonesia", correct: false}
        ]
      },
      {
        content: "What is the capital city of Australia?",
        question_type: "multiple_choice",
        answers: [
          {content: "Canberra", correct: true},
          {content: "Sydney", correct: false},
          {content: "Melbourne", correct: false},
          {content: "Brisbane", correct: false}
        ]
      }
    ]
  },
  {
    title: "Entertainment",
    description: "Entertainment trivia questions",
    questions: [
      {
        content: "Who directed the movie 'Inception'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Christopher Nolan", correct: true},
          {content: "Steven Spielberg", correct: false},
          {content: "James Cameron", correct: false},
          {content: "Quentin Tarantino", correct: false}
        ]
      },
      {
        content: "Which artist painted the Mona Lisa?",
        question_type: "multiple_choice",
        answers: [
          {content: "Leonardo da Vinci", correct: true},
          {content: "Vincent van Gogh", correct: false},
          {content: "Pablo Picasso", correct: false},
          {content: "Claude Monet", correct: false}
        ]
      },
      {
        content: "Who is known as the 'King of Pop'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Michael Jackson", correct: true},
          {content: "Elvis Presley", correct: false},
          {content: "Prince", correct: false},
          {content: "Freddie Mercury", correct: false}
        ]
      },
      {
        content: "Which movie won the first Academy Award for Best Picture?",
        question_type: "multiple_choice",
        answers: [
          {content: "Wings", correct: true},
          {content: "The Jazz Singer", correct: false},
          {content: "Sunrise", correct: false},
          {content: "Metropolis", correct: false}
        ]
      },
      {
        content: "Who wrote the novel '1984'?",
        question_type: "multiple_choice",
        answers: [
          {content: "George Orwell", correct: true},
          {content: "Aldous Huxley", correct: false},
          {content: "Ray Bradbury", correct: false},
          {content: "Arthur C. Clarke", correct: false}
        ]
      },
      {
        content: "Which band released the album 'Abbey Road'?",
        question_type: "multiple_choice",
        answers: [
          {content: "The Beatles", correct: true},
          {content: "The Rolling Stones", correct: false},
          {content: "Led Zeppelin", correct: false},
          {content: "The Who", correct: false}
        ]
      },
      {
        content: "In which year was the first Harry Potter book published?",
        question_type: "multiple_choice",
        answers: [
          {content: "1997", correct: true},
          {content: "1995", correct: false},
          {content: "2000", correct: false},
          {content: "1999", correct: false}
        ]
      },
      {
        content: "Which actress played the lead role in the movie 'Pretty Woman'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Julia Roberts", correct: true},
          {content: "Sandra Bullock", correct: false},
          {content: "Meg Ryan", correct: false},
          {content: "Meryl Streep", correct: false}
        ]
      },
      {
        content: "Who won the Grammy for Album of the Year in 2021?",
        question_type: "multiple_choice",
        answers: [
          {content: "Taylor Swift", correct: true},
          {content: "Beyoncé", correct: false},
          {content: "Billie Eilish", correct: false},
          {content: "Post Malone", correct: false}
        ]
      },
      {
        content: "Which television series is known for the phrase 'Winter is Coming'?",
        question_type: "multiple_choice",
        answers: [
          {content: "Game of Thrones", correct: true},
          {content: "The Witcher", correct: false},
          {content: "Breaking Bad", correct: false},
          {content: "Stranger Things", correct: false}
        ]
      }
    ]
  }
]

trivia_data.each_with_index do |course_data, course_index|
  course = Course.create!(
    title: course_data[:title],
    description: course_data[:description],
    teacher_id: teacher.id,
    questions_attributes: course_data[:questions].map do |question_data|
      {
        content: question_data[:content],
        question_type: question_data[:question_type] || "multiple_choice",
        answers_attributes:
          if question_data[:question_type] == "open_answer"
            [
              {
                content: question_data[:correct_answer],
                correct: true
              }
            ]
          else
            question_data[:answers]&.map do |answer_data|
              {
                content: answer_data[:content],
                correct: answer_data[:correct]
              }
            end
          end
      }
    end
  )
end

# Register all students for all courses
puts "Registering students for courses..."

students = User.where(role: :student)
courses = Course.all

courses.each do |course|
  students.each do |student|
    Registration.create(user: student, course: course)
  end
end

puts "All students have been registered for all courses."

puts "Creating 2 memberships..."

Membership.create([
  {name: "Basis", price: 5.99, interval: "1 month"},
  {name: "Docenten", price: 12.99, interval: "1 month"}
])

puts "#{Membership.count} Memberships created successfully!"

puts "Seed data with demo questions created successfully!"
