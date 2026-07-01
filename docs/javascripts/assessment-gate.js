(function () {
  var passedAssessments = new Set();
  var lockedNextHref = null;

  document.addEventListener("DOMContentLoaded", function () {
    injectStyles();
    document.addEventListener("click", blockLockedNextNavigation, true);

    var bindings = findAssessmentBindings();
    if (bindings.length === 0) {
      return;
    }

    lockNextNavigation();
    bindings.forEach(renderAssessmentBinding);
  });

  function findAssessmentBindings() {
    var root = document.querySelector(".md-content") || document.body;
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_COMMENT);
    var bindings = [];
    var node = walker.nextNode();

    while (node) {
      var match = node.nodeValue.match(
        /boundScenarioId:\s*([A-Za-z0-9._-]+)(?:\s+retake=(true|false))?/
      );

      if (match) {
        bindings.push({
          id: match[1],
          retake: match[2] === "true",
          marker: node
        });
      }

      node = walker.nextNode();
    }

    return bindings;
  }

  function renderAssessmentBinding(binding) {
    var container = document.createElement("section");
    container.className = "assessment-gate";
    container.id = "assessment-" + binding.id;
    container.setAttribute("aria-live", "polite");
    container.appendChild(createStatus("Loading knowledge check..."));
    insertAfterMarker(binding.marker, container);

    var storageKey = "enablement-assessment:" + location.pathname + ":" + binding.id;
    if (!binding.retake && localStorage.getItem(storageKey) === "passed") {
      container.replaceChildren(createStatus("Knowledge check completed."));
      passedAssessments.add(binding.id);
      unlockNextNavigationIfReady();
      return;
    }

    fetch(getAssessmentUrl(binding.id))
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Assessment not found: " + binding.id);
        }

        return response.json();
      })
      .then(function (assessment) {
        renderAssessment(container, assessment, binding, storageKey);
      })
      .catch(function (error) {
        container.replaceChildren(createStatus(error.message));
      });
  }

  function renderAssessment(container, assessment, binding, storageKey) {
    var questions = Array.isArray(assessment.questions)
      ? assessment.questions.filter(isMultipleChoiceQuestion)
      : [];

    if (questions.length === 0) {
      container.replaceChildren(createStatus("This assessment has no multiple-choice questions."));
      return;
    }

    var title = document.createElement("h2");
    title.textContent = assessment.title || "Knowledge Check";

    var intro = document.createElement("p");
    intro.textContent =
      assessment.description || "Answer every question correctly to unlock the next chapter.";

    var form = document.createElement("form");
    form.className = "assessment-gate__form";

    questions.forEach(function (question, index) {
      form.appendChild(renderQuestion(question, index));
    });

    var feedback = document.createElement("p");
    feedback.className = "assessment-gate__feedback";

    var submit = document.createElement("button");
    submit.className = "md-button md-button--primary";
    submit.type = "submit";
    submit.textContent = "Check answers";

    form.appendChild(submit);
    form.appendChild(feedback);
    container.replaceChildren(title, intro, form);

    form.addEventListener("submit", function (event) {
      event.preventDefault();

      var result = gradeQuestions(form, questions);
      feedback.textContent = result.message;
      feedback.className = result.passed
        ? "assessment-gate__feedback assessment-gate__feedback--passed"
        : "assessment-gate__feedback assessment-gate__feedback--failed";

      if (!result.passed) {
        return;
      }

      if (!binding.retake) {
        localStorage.setItem(storageKey, "passed");
      }

      passedAssessments.add(binding.id);
      submit.disabled = true;
      unlockNextNavigationIfReady();
    });
  }

  function renderQuestion(question, index) {
    var fieldset = document.createElement("fieldset");
    fieldset.className = "assessment-gate__question";

    var legend = document.createElement("legend");
    legend.textContent = String(index + 1) + ". " + (question.title || question.content);
    fieldset.appendChild(legend);

    if (question.title && question.content) {
      var content = document.createElement("p");
      content.textContent = question.content;
      fieldset.appendChild(content);
    }

    question.options.forEach(function (option) {
      var label = document.createElement("label");
      label.className = "assessment-gate__option";

      var input = document.createElement("input");
      input.type = "radio";
      input.name = question.id;
      input.value = option.id;
      input.required = true;

      var text = document.createElement("span");
      text.textContent = option.text;

      label.appendChild(input);
      label.appendChild(text);
      fieldset.appendChild(label);
    });

    return fieldset;
  }

  function gradeQuestions(form, questions) {
    var missed = [];

    questions.forEach(function (question) {
      var selected = form.querySelector('input[name="' + question.id + '"]:checked');
      var correctAnswer = question.correctAnswer || getCorrectOptionId(question.options);

      if (!selected || selected.value !== correctAnswer) {
        missed.push(question.title || question.id);
      }
    });

    if (missed.length === 0) {
      return {
        passed: true,
        message: "Correct. The next chapter is now unlocked."
      };
    }

    return {
      passed: false,
      message: "Not yet. Review and try again before continuing."
    };
  }

  function isMultipleChoiceQuestion(question) {
    return (
      question &&
      question.type === "multiple-choice" &&
      typeof question.id === "string" &&
      Array.isArray(question.options)
    );
  }

  function getCorrectOptionId(options) {
    var correct = options.find(function (option) {
      return option.isCorrect === true;
    });

    return correct ? correct.id : undefined;
  }

  function insertAfterMarker(marker, element) {
    if (marker.parentNode) {
      marker.parentNode.insertBefore(element, marker.nextSibling);
      return;
    }

    var content = document.querySelector(".md-content__inner") || document.body;
    content.appendChild(element);
  }

  function createStatus(message) {
    var status = document.createElement("p");
    status.className = "assessment-gate__status";
    status.textContent = message;
    return status;
  }

  function getAssessmentUrl(id) {
    return getSiteRootUrl() + "assessments/" + encodeURIComponent(id) + ".json";
  }

  function getSiteRootUrl() {
    var script = Array.from(document.scripts).find(function (item) {
      return item.src.indexOf("/javascripts/assessment-gate.js") !== -1;
    });

    if (!script) {
      return new URL("./", document.baseURI).toString();
    }

    return script.src.replace(/javascripts\/assessment-gate\.js(?:\?.*)?$/, "");
  }

  function lockNextNavigation() {
    var nextLink = document.querySelector("a.md-footer__link--next");
    if (!nextLink) {
      return;
    }

    lockedNextHref = new URL(nextLink.href, document.baseURI).href;
    updateNextLinks(true);
  }

  function unlockNextNavigationIfReady() {
    var required = findAssessmentBindings().map(function (binding) {
      return binding.id;
    });
    var allPassed = required.every(function (id) {
      return passedAssessments.has(id);
    });

    if (allPassed) {
      updateNextLinks(false);
      lockedNextHref = null;
    }
  }

  function updateNextLinks(locked) {
    if (!lockedNextHref) {
      return;
    }

    Array.from(document.querySelectorAll("a")).forEach(function (link) {
      if (new URL(link.href, document.baseURI).href !== lockedNextHref) {
        return;
      }

      link.classList.toggle("assessment-gate__locked-link", locked);
      link.setAttribute("aria-disabled", locked ? "true" : "false");
      link.title = locked ? "Complete the knowledge check to unlock the next chapter." : "";
    });
  }

  function blockLockedNextNavigation(event) {
    if (!lockedNextHref) {
      return;
    }

    var link = event.target.closest ? event.target.closest("a") : null;
    if (!link || new URL(link.href, document.baseURI).href !== lockedNextHref) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();

    var assessment = document.querySelector(".assessment-gate");
    if (assessment) {
      assessment.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  function injectStyles() {
    var style = document.createElement("style");
    style.textContent = [
      ".assessment-gate { border: 1px solid var(--md-default-fg-color--lightest); border-radius: .4rem; margin: 2rem 0; padding: 1rem; }",
      ".assessment-gate__question { border: 0; margin: 1rem 0; padding: 0; }",
      ".assessment-gate__question legend { font-weight: 700; margin-bottom: .5rem; }",
      ".assessment-gate__option { align-items: flex-start; display: flex; gap: .5rem; margin: .35rem 0; }",
      ".assessment-gate__feedback { font-weight: 700; margin: 1rem 0 0; }",
      ".assessment-gate__feedback--passed { color: var(--md-typeset-a-color); }",
      ".assessment-gate__feedback--failed { color: var(--md-code-hl-special-color); }",
      ".assessment-gate__locked-link { opacity: .45; pointer-events: none; }"
    ].join("\n");
    document.head.appendChild(style);
  }
})();
