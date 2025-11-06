import UIKit

protocol AlertPresenterProtocol {
    func requestAlertPresenter(model: AlertModel?)
}

protocol AlertPresenterDelegate: AnyObject {
    func didAlertButtonTouch(alert: UIAlertController?)
}

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var viewController: (UIViewController&AlertPresenterDelegate)?
    
    init(_ viewController: UIViewController&AlertPresenterDelegate) {
        self.viewController = viewController
    }
    
    func requestAlertPresenter(model: AlertModel?) {
        guard let model else { return }
        
        let alert = UIAlertController(title: nil,
                                      message: model.message,
                                      preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: model.buttonText, style: .destructive) {[weak self] _ in
            model.completion()
            self?.viewController?.didAlertButtonTouch(alert: alert)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel_button", comment: "Кнопка отмены в алерте"), style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
