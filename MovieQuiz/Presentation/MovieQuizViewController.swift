import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
   
    
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() 
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            }
            
        alertPresenter?.show(with: model)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel!.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel!.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: self)
        presenter.viewController = self
        
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        self.noButton.isEnabled = true
        self.yesButton.isEnabled = true
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else {
                print("Не удалось получить данные")
                return
            }
            let viewModel = QuizResultsViewModel (title: "Этот раунд окончен",
                                                  text: message(statisticService: statisticService,
                                                                correct: correctAnswers,
                                                                total: presenter.questionsAmount),
                                                  buttonText: "Сыграть еще раз"
            )
            showFinalResult(result: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showFinalResult(result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: { [weak self] in
            guard let self = self else { return }
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.show(with: alertModel)
    }
    
    func message(statisticService: StatisticService, correct: Int, total: Int) -> String{
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        let bestGame = statisticService.bestGame
        let message = """
Ваш результат: \(correct)/\(total)
Колличество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
        return message
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor :UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
}


