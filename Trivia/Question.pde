static final int MAX_POINT_VALUE = 3;
static final int MAX_GUESSES = 3;
static final int FULL_SIZE = 10;

class Question {
    String question;
    int answer;
    int attempts;
    int points;
    int size = 0;
    
    Question(String question, String answer) {
        this.question = question;
        this.answer = int(answer);
        attempts = 0;
        size = 0;
        points = MAX_POINT_VALUE;
    }
    
    void reset(){
        attempts = 0;
        size = 0;
    }
}
