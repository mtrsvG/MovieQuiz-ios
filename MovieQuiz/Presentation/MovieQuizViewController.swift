import UIKit


final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenterProtocol?
   

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel!.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel!.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        showLoadingIndicator()
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        self.imageView.layer.borderWidth = 0
        self.noButton.isEnabled = true
        self.yesButton.isEnabled = true
    }
    
    func showFinalResult(result: QuizResultsViewModel) {
        let message = presenter.makeResultMassage()
        
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText,
                                    completion: { [weak self] in
            guard let self = self else { return }
            presenter.restartGame()
        })
        alertPresenter?.show(with: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            }
        alertPresenter?.show(with: model)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor :UIColor.ypRed.cgColor
    }
}


