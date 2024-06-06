// В своём rails проекте реализовать:
// Кнопка с текстом “Время” справа внизу, которая появляется через 5 секунд после загрузки root страницы
// (у каждого она своя), на других не должно. (для кнопки должны быть минимум установлены свойства цвета и паддинги,
// какие - на своё усмотрение)
// по нажатию на кнопку должно открыться окно справа внизу, кнопка скрыться (как на скринах.
// Тут можно посмотреть пример https://winvestor.ru/ . Списывать оттуда поведение не нужно, у нас всё проще)
//
//     Внутри этого окна отображаем текущее время в формате 15:30:22 (часы:минуты:секунды).
//    Также отображаем крестик, который закрывает окно. После закрытия окна должна появится кнопка.
//
//     Ограничение:
//
// кнопка и открывающееся по клику на неё окно должны быть созданы с помощью js
//
// все стили для них также должны быть написаны на js

const securities = [
    { name: 'Сбер Банк', ticker: 'SBER' },
    { name: 'МТС', ticker: 'MTSS' },
    { name: 'Тинькофф групп', ticker: 'TCS' },
    { name: 'Московская биржа', ticker: 'MOEX' }
];

document.addEventListener('DOMContentLoaded', () => {
    const btn = createButton("Поиск", ["btn", "btn-outline-info"], {
        display: "none",
        position: "absolute",
        bottom: "50px",
        right: "50px",
        padding: "10px 20px",
    });

    const modal = createModal({
        display: "none",
        position: "absolute",
        bottom: "0",
        right: "0",
        width: "400px",
        height: "400px",
        margin: "20px",
        padding: "20px",
        backgroundColor: "#fff",
        boxShadow: "0px 0px 10px rgba(0, 0, 0, 0.5)",
        borderRadius: "5px"
    });

    const form = document.createElement('form');
    const label = createLabel('Инструмент', { marginBottom: "10px" });
    const input = createInput(['form-control'], { marginBottom: "10px" });

    form.append(label, input);
    modal.appendChild(form);

    const output = document.createElement('p');
    modal.appendChild(output);

    output.innerText = `Результаты:\n${findByTicker(input.value)}`;

    input.addEventListener('input', () => {
        output.innerText = `Результаты:\n${findByTicker(input.value)}`;
    })

    document.querySelector('html').onclick = (e) => {
        if (!modal.contains(e.target) && e.target !== btn) {
            toggleDisplay(modal, btn);
        }
    };

    btn.onclick = () => {
        toggleDisplay(btn, modal);
    };

    const divBtn = document.querySelector("main");
    divBtn.append(btn, modal);

    setTimeout(() => {
        btn.style.display = 'block';
    }, 1000);
});

function createButton(text, classes, styles) {
    const button = document.createElement('button');
    button.innerText = text;
    button.classList.add(...classes);
    button.setAttribute("type", "button");
    Object.assign(button.style, styles);
    return button;
}

function createModal(styles) {
    const modal = document.createElement('div');
    Object.assign(modal.style, styles);
    return modal;
}

function createLabel(text, styles) {
    const label = document.createElement('label');
    label.innerText = text;
    Object.assign(label.style, styles);
    return label;
}

function createInput(classes, styles) {
    const input = document.createElement('input');
    input.classList.add(...classes);
    Object.assign(input.style, styles);
    return input;
}

function toggleDisplay(hideElement, showElement) {
    hideElement.style.display = "none";
    showElement.style.display = "block";
}

function findByTicker(pattern) {
    if (pattern === "") {
        return securities.map(el => el.ticker);
    }
    pattern = pattern.toLowerCase();

    return securities.reduce((tickers, security) => {
        if (security.name.toLowerCase().includes(pattern)) {
            tickers.push(security.ticker);
        }
        return tickers;
    }, []);
}