import UIKit
import Foundation

class CollectionViewController: UICollectionViewController {
    private var items = [Item]() // The list of strings displayed in the collection view
    var cancellables: Set<AnyTaskCancellable> = []
    let updateCollectionService = UpdateCollectionServiceAsyncPublish()

    init()
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        super.init(collectionViewLayout: layout)
        subscribeToUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func subscribeToUpdates()
    {
        Task { [weak self] in
            for await (item, updateType) in UpdateCollectionServiceAsyncPublish.publisher {
                // `self` MUST NOT be referenced directly in this for loop context or causes a retain cycle.
                guard let self else { continue }
                
                switch updateType
                {
                case .changeNumber:
                    if let itemIndex = items.firstIndex(where: {$0.id == item.id})
                    {
                        collectionView.reloadItems(at: [IndexPath(row: itemIndex, section: 0)])
                    }
                case .changeString:
                    break
                case .newItem:
                    items.append(item)
                    collectionView.reloadData()
                }
            }
        }.store(in: &cancellables)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 50) // Adjust cell size as needed
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        let addButton = UIButton()
        addButton.setTitle("AddItem", for: .normal)
        addButton.backgroundColor = .green.withAlphaComponent(0.80)
        addButton.addTarget(updateCollectionService, action: #selector(updateCollectionService.addItem), for: .touchDown)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        let updateCountButton = UIButton()
        updateCountButton.setTitle("+1 last item", for: .normal)
        updateCountButton.backgroundColor = .green.withAlphaComponent(0.80)
        updateCountButton.addTarget(updateCollectionService, action: #selector(updateCollectionService.updateCountForLastItem), for: .touchDown)
        updateCountButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(updateCountButton)
        NSLayoutConstraint.activate([
            updateCountButton.widthAnchor.constraint(equalToConstant: 100),
            updateCountButton.heightAnchor.constraint(equalToConstant: 50),
            updateCountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            updateCountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        let incrementAllButton = UIButton()
        incrementAllButton.setTitle("+1 all items", for: .normal)
        incrementAllButton.backgroundColor = .green.withAlphaComponent(0.80)
        incrementAllButton.addTarget(updateCollectionService, action: #selector(updateCollectionService.updateCountEveryItem), for: .touchDown)
        incrementAllButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incrementAllButton)
        NSLayoutConstraint.activate([
            incrementAllButton.widthAnchor.constraint(equalToConstant: 100),
            incrementAllButton.heightAnchor.constraint(equalToConstant: 50),
            incrementAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 200),
            incrementAllButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        let reloadDataButton = UIButton()
        reloadDataButton.setTitle(".reloadData()", for: .normal)
        reloadDataButton.backgroundColor = .green.withAlphaComponent(0.80)
        reloadDataButton.addTarget(self, action: #selector(reloadAllItems), for: .touchDown)
        reloadDataButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reloadDataButton)
        NSLayoutConstraint.activate([
            reloadDataButton.widthAnchor.constraint(equalToConstant: 100),
            reloadDataButton.heightAnchor.constraint(equalToConstant: 50),
            reloadDataButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300),
            reloadDataButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
    
    @objc
    private func reloadAllItems()
    {
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Clean up previous cell content
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false  // Enable Auto Layout for the stack view
        
        let nameLabel = UILabel()
        nameLabel.text = items[indexPath.row].name
        nameLabel.textAlignment = .center
        
        let countLabel = UILabel()
        countLabel.text = "\(items[indexPath.row].count)"
        countLabel.textAlignment = .center
        
        // Add labels to the stack view
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(countLabel)
        
        // Add the stack view to the cell's contentView
        cell.contentView.addSubview(stackView)
        
        // Set stack view constraints relative to the cell's contentView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
        ])
        
        return cell
    }

    
    // MARK: - Adding Items
    func addItem(_ item: Item) {
        items.append(item)
        collectionView?.reloadData()
    }
}
